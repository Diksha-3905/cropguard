from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import firebase_admin
from firebase_admin import credentials
import logging
import os
import json

from routers import diagnose, voice, sync, health

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not firebase_admin._apps:
        cred_json = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS_JSON")
        if cred_json:
            cred_dict = json.loads(cred_json)
            cred = credentials.Certificate(cred_dict)
        else:
            cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred)
        logger.info("Firebase initialized")
    yield


app = FastAPI(title="CropGuard Backend", version="1.0.0", lifespan=lifespan)

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

app.include_router(health.router)
app.include_router(diagnose.router)
app.include_router(voice.router)
app.include_router(sync.router)
