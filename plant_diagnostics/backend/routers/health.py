from fastapi import APIRouter
import anthropic
import os

router = APIRouter(tags=["health"])


@router.get("/health")
async def health():
    return {
        "status": "ok",
        "services": {
            "anthropic": bool(os.environ.get("ANTHROPIC_API_KEY")),
            "deepgram": bool(os.environ.get("DEEPGRAM_API_KEY")),
            "elevenlabs": bool(os.environ.get("ELEVENLABS_API_KEY")),
            "supabase": bool(os.environ.get("SUPABASE_URL")),
        },
    }
