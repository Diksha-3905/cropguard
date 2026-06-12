# CropGuard 🌿

**Real-Time Multimodal Plant Disease Diagnostics Assistant with Offline-First Sync**

Capture a leaf → get instant AI disease classification → ask voice follow-up questions → works fully offline.

---

## What's built

| Phase | Feature | Status |
|---|---|---|
| 0 | Flutter APK, FastAPI backend, Supabase, CI/CD | ✅ |
| 1 | Camera capture, Claude vision diagnosis, OOD rejection, confidence score | ✅ |
| 2 | Voice Q&A (STT → LLM → TTS), barge-in | ⚠️ Partial |
| 3 | Offline queue, vector clock sync | ✅ |
| 4 | PlantVillage eval, latency instrumentation | 📋 Designed |

## Stack

- **Flutter** (Android APK + iOS ready)
- **FastAPI** on Railway
- **Supabase** (Postgres, Storage, Realtime)
- **Claude Sonnet 4.6** — vision diagnosis
- **Deepgram** — STT
- **ElevenLabs** — TTS
- **Drift** — local SQLite

## Quick start

### Prerequisites
- Flutter SDK 3.22+
- Python 3.12+
- Accounts: Supabase, Railway, Anthropic

### Backend

```bash
cd backend
cp ../.env.example .env  # fill in keys
pip install -r requirements.txt
uvicorn main:app --reload
# → http://localhost:8000/docs
```

### Flutter

```bash
cd flutter_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY \
  --dart-define=BACKEND_URL=http://10.0.2.2:8000
```

### Build APK

```bash
cd flutter_app
flutter build apk \
  --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY \
  --dart-define=BACKEND_URL=https://your-worker.railway.app
# → build/app/outputs/flutter-apk/app-release.apk
```

### Database setup

1. Create Supabase project
2. Run `supabase_schema.sql` in SQL Editor
3. Create storage bucket `leaf-images`

## Architecture

```
Flutter App
  ├── Camera → image_picker
  ├── Local DB → Drift/SQLite
  ├── Voice → record + just_audio
  └── Sync → SyncService (vector clocks)
       ↓  ↑
FastAPI Backend (Railway)
  ├── POST /diagnose → Claude Sonnet vision
  ├── POST /voice/ask → Deepgram STT → Claude → ElevenLabs TTS
  ├── POST /sync → vector clock conflict resolution
  └── GET  /health
       ↓  ↑
Supabase
  ├── diagnoses (table + RLS)
  ├── voice_sessions
  └── leaf-images (storage)
```

## Environment variables

See `.env.example` for all required variables. Never commit real keys.

## Project docs

- [`docs/PROJECT_REPORT.md`](docs/PROJECT_REPORT.md) — full 8-section report
- [`PROMPTS.md`](PROMPTS.md) — raw AI prompt log
- [`supabase_schema.sql`](supabase_schema.sql) — database setup

## License

MIT
