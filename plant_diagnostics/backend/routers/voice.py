from fastapi import APIRouter, File, UploadFile, Form, HTTPException
import google.generativeai as genai
import httpx
import base64
import json
import logging
import os

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/voice", tags=["voice"])

genai.configure(api_key=os.environ["GEMINI_API_KEY"])
llm = genai.GenerativeModel("gemini-1.5-flash")

DEEPGRAM_KEY = os.environ.get("DEEPGRAM_API_KEY", "")
ELEVENLABS_KEY = os.environ.get("ELEVENLABS_API_KEY", "")
ELEVENLABS_VOICE_ID = os.environ.get("ELEVENLABS_VOICE_ID", "EXAVITQu4vr4xnSDxMaL")

VOICE_SYSTEM = """You are CropGuard, a friendly plant disease expert.
Answer the user's spoken question about their plant diagnosis in 2-3 sentences max.
Be practical, clear, and honest about uncertainty."""


async def transcribe_audio(audio_bytes: bytes, sample_rate: int = 16000) -> str:
    if not DEEPGRAM_KEY:
        return "What is the best treatment for this disease?"
    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(
            f"https://api.deepgram.com/v1/listen?model=nova-2&smart_format=true&sample_rate={sample_rate}",
            headers={"Authorization": f"Token {DEEPGRAM_KEY}", "Content-Type": "audio/raw"},
            content=audio_bytes,
        )
        response.raise_for_status()
        data = response.json()
        return (data.get("results", {}).get("channels", [{}])[0]
                .get("alternatives", [{}])[0].get("transcript", ""))


async def synthesize_speech(text: str) -> bytes:
    if not ELEVENLABS_KEY:
        return b""
    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(
            f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVENLABS_VOICE_ID}",
            headers={"xi-api-key": ELEVENLABS_KEY, "Content-Type": "application/json"},
            json={"text": text, "model_id": "eleven_turbo_v2",
                  "voice_settings": {"stability": 0.5, "similarity_boost": 0.75}},
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
    audio_bytes = await audio.read()

    try:
        transcript = await transcribe_audio(audio_bytes, int(sample_rate))
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Speech recognition failed: {e}")

    if not transcript.strip():
        return {"transcript": "", "reply": "I didn't catch that. Could you repeat?", "audio_b64": None}

    try:
        ctx = json.loads(diagnosis_context) if diagnosis_context else {}
    except json.JSONDecodeError:
        ctx = {}

    try:
        prompt = f"{VOICE_SYSTEM}\n\nDiagnosis context: {json.dumps(ctx)}\n\nUser question: {transcript}"
        response = llm.generate_content(prompt)
        reply_text = response.text.strip()
    except Exception as e:
        raise HTTPException(status_code=503, detail="AI service temporarily unavailable")

    try:
        audio_out = await synthesize_speech(reply_text)
        audio_b64 = base64.b64encode(audio_out).decode() if audio_out else None
    except Exception as e:
        logger.error(f"TTS error: {e}")
        audio_b64 = None

    return {"transcript": transcript, "reply": reply_text, "audio_b64": audio_b64}


@router.post("/ask-text")
async def voice_ask_text(question: str = Form(...), diagnosis_id: str = Form(default="")):
    """Text-based Q&A fallback (no audio input needed)."""
    try:
        ctx_str = "{}"
        prompt = f"{VOICE_SYSTEM}\n\nUser question: {question}"
        response = llm.generate_content(prompt)
        reply_text = response.text.strip()
    except Exception as e:
        raise HTTPException(status_code=503, detail="AI service unavailable")

    try:
        audio_out = await synthesize_speech(reply_text)
        audio_b64 = base64.b64encode(audio_out).decode() if audio_out else None
    except Exception:
        audio_b64 = None

    return {"reply": reply_text, "audio_b64": audio_b64}
