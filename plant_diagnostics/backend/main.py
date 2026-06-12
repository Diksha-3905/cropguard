from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import firebase_admin
from firebase_admin import credentials
import logging
import os

from routers import diagnose, voice, sync, health

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize Firebase Admin SDK
    # On Railway: set GOOGLE_APPLICATION_CREDENTIALS_JSON env var
    # with the contents of your serviceAccountKey.json
    cred_json = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS_JSON")
    if cred_json:
        import json, tempfile
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            f.write(cred_json)
            cred_path = f.name
        cred = credentials.Certificate(cred_path)
    elif os.path.exists("serviceAccountKey.json"):
        cred = credentials.Certificate("serviceAccountKey.json")
    else:
        # Use application default credentials (works on Google Cloud)
        cred = credentials.ApplicationDefault()

    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)

    logger.info("CropGuard backend started with Firebase")
    yield
    logger.info("Shutting down")


app = FastAPI(
    title="CropGuard Backend",
    description="Plant diagnostics API — vision, voice, and offline sync",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(diagnose.router)
app.include_router(voice.router)
app.include_router(sync.router)
