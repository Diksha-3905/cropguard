from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

from routers import diagnose, voice, sync, health

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("CropGuard backend starting up")
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
