from fastapi import APIRouter
import os

router = APIRouter(tags=["health"])

@router.get("/health")
async def health():
    return {
        "status": "ok",
        "services": {
            "gemini": bool(os.environ.get("GEMINI_API_KEY")),
            "deepgram": bool(os.environ.get("DEEPGRAM_API_KEY")),
            "elevenlabs": bool(os.environ.get("ELEVENLABS_API_KEY")),
            "firebase": bool(os.environ.get("GOOGLE_APPLICATION_CREDENTIALS_JSON")),
        },
    }
