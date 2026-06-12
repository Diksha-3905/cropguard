"""
Voice Q&A endpoint.

Pipeline:
  Audio (PCM/WAV) → Deepgram STT → Claude LLM (with diagnosis context as tool)
  → ElevenLabs TTS → base64 audio response

Barge-in is handled client-side (Flutter stops playback when new audio arrives).
Server side: each /voice/ask call is stateless; conversation history is in the request.
"""

from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from pydantic import BaseModel
import anthropic
import httpx
import base64
import json
import logging
import os

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/voice", tags=["voice"])

claude = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
DEEPGRAM_KEY = os.environ.get("DEEPGRAM_API_KEY", "")
ELEVENLABS_KEY = os.environ.get("ELEVENLABS_API_KEY", "")
ELEVENLABS_VOICE_ID = os.environ.get("ELEVENLABS_VOICE_ID", "EXAVITQu4vr4xnSDxMaL")


VOICE_SYSTEM = """You are CropGuard, a friendly plant disease expert assistant.
The user has just received a diagnosis for their plant. Answer their spoken follow-up questions
clearly and concisely (2–4 sentences max for voice). 
Be practical, evidence-based, and honest about uncertainty.
You have access to the diagnosis context via the get_diagnosis_context tool."""


async def transcribe_audio(audio_bytes: bytes, sample_rate: int = 16000) -> str:
    """Send audio to Deepgram for STT."""
    if not DEEPGRAM_KEY:
        # Fallback: return placeholder when key not set (for testing)
        return "What is the best treatment for this disease?"

    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(
            f"https://api.deepgram.com/v1/listen?model=nova-2&smart_format=true&sample_rate={sample_rate}",
            headers={
                "Authorization": f"Token {DEEPGRAM_KEY}",
                "Content-Type": "audio/raw",
            },
            content=audio_bytes,
        )
        response.raise_for_status()
        data = response.json()
        transcript = (
            data.get("results", {})
            .get("channels", [{}])[0]
            .get("alternatives", [{}])[0]
            .get("transcript", "")
        )
        return transcript


async def synthesize_speech(text: str) -> bytes:
    """Convert text to speech via ElevenLabs."""
    if not ELEVENLABS_KEY:
        return b""  # Empty audio in test mode

    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(
            f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVENLABS_VOICE_ID}",
            headers={
                "xi-api-key": ELEVENLABS_KEY,
                "Content-Type": "application/json",
            },
            json={
                "text": text,
                "model_id": "eleven_turbo_v2",
                "voice_settings": {"stability": 0.5, "similarity_boost": 0.75},
            },
        )
        response.raise_for_status()
        return response.content


@router.post("/ask")
async def voice_ask(
    audio: UploadFile = File(...),
    diagnosis_id: str = Form(default=""),
    sample_rate: str = Form(default="16000"),
    diagnosis_context: str = Form(default="{}"),
):
    """
    Accept raw PCM audio, transcribe, run through Claude agent with
    diagnosis context, synthesize response audio.
    """
    audio_bytes = await audio.read()

    # 1. STT
    try:
        transcript = await transcribe_audio(audio_bytes, int(sample_rate))
    except Exception as e:
        logger.error(f"STT error: {e}")
        raise HTTPException(status_code=502, detail=f"Speech recognition failed: {e}")

    if not transcript.strip():
        return {"transcript": "", "reply": "I didn't catch that. Could you repeat?", "audio_b64": None}

    # 2. Parse diagnosis context
    try:
        ctx = json.loads(diagnosis_context) if diagnosis_context else {}
    except json.JSONDecodeError:
        ctx = {}

    # 3. LLM agent
    tools = [
        {
            "name": "get_diagnosis_context",
            "description": "Returns the current plant diagnosis result to answer follow-up questions.",
            "input_schema": {
                "type": "object",
                "properties": {},
                "required": [],
            },
        }
    ]

    messages = [{"role": "user", "content": transcript}]

    try:
        llm_response = claude.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=512,
            system=VOICE_SYSTEM,
            tools=tools,
            messages=messages,
        )

        # Handle tool calls
        reply_text = ""
        for block in llm_response.content:
            if block.type == "tool_use" and block.name == "get_diagnosis_context":
                # Provide diagnosis context back to Claude
                messages.append({"role": "assistant", "content": llm_response.content})
                messages.append({
                    "role": "user",
                    "content": [
                        {
                            "type": "tool_result",
                            "tool_use_id": block.id,
                            "content": json.dumps(ctx),
                        }
                    ],
                })
                # Second LLM call with context
                follow_up = claude.messages.create(
                    model="claude-sonnet-4-6",
                    max_tokens=512,
                    system=VOICE_SYSTEM,
                    tools=tools,
                    messages=messages,
                )
                reply_text = next(
                    (b.text for b in follow_up.content if hasattr(b, "text")), ""
                )
                break
            elif hasattr(block, "text"):
                reply_text = block.text

        if not reply_text:
            reply_text = "I'm not sure about that. Please consult a local agronomist."

    except anthropic.APIConnectionError:
        raise HTTPException(status_code=503, detail="AI service temporarily unavailable")

    # 4. TTS
    try:
        audio_bytes_out = await synthesize_speech(reply_text)
        audio_b64 = base64.b64encode(audio_bytes_out).decode() if audio_bytes_out else None
    except Exception as e:
        logger.error(f"TTS error: {e}")
        audio_b64 = None  # Graceful degradation: return text even if TTS fails

    return {
        "transcript": transcript,
        "reply": reply_text,
        "audio_b64": audio_b64,
    }
