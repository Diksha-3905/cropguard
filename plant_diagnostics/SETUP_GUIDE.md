# SETUP GUIDE — Step by step

Follow this exactly in order. Takes about 1–2 hours.

---

## STEP 1 — Accounts you need (all free tier)

Sign up for these if you haven't already:

1. **GitHub** — https://github.com (store your code)
2. **Supabase** — https://supabase.com (database)
3. **Railway** — https://railway.app (backend hosting)
4. **Anthropic** — https://console.anthropic.com (AI vision API)
5. **Deepgram** — https://console.deepgram.com (speech-to-text)
6. **ElevenLabs** — https://elevenlabs.io (text-to-speech)

Get your API keys from each dashboard and keep them in a notepad.

---

## STEP 2 — Set up Supabase

1. Go to https://supabase.com → New Project → give it any name
2. Wait for it to spin up (~1 min)
3. Go to **SQL Editor** (left sidebar) → paste the entire contents of `supabase_schema.sql` → click **Run**
4. Go to **Storage** → **New bucket** → name it `leaf-images` → uncheck "public"
5. Go to **Project Settings** → **API** → copy:
   - `Project URL` (looks like `https://abcxyz.supabase.co`)
   - `anon public` key
   - `service_role` key (keep this secret — backend only)

---

## STEP 3 — Deploy the backend to Railway

1. Go to https://railway.app → New Project → Deploy from GitHub repo
2. First push your code to GitHub (Step 4 below), then come back here
3. In Railway dashboard → your service → **Variables** → add these:

```
ANTHROPIC_API_KEY      = sk-ant-...
SUPABASE_URL           = https://YOUR.supabase.co
SUPABASE_SERVICE_ROLE_KEY = eyJ...
DEEPGRAM_API_KEY       = ...
ELEVENLABS_API_KEY     = ...
ELEVENLABS_VOICE_ID    = EXAVITQu4vr4xnSDxMaL
```

4. Railway auto-detects Python and deploys using `railway.toml`
5. After deploy, copy your Railway URL (looks like `https://cropguard-backend.up.railway.app`)
6. Test it: open `https://YOUR-RAILWAY-URL/health` in browser — should show `{"status":"ok"}`

---

## STEP 4 — Push to GitHub

On your computer with Git installed:

```bash
# Navigate to the project folder (where you extracted the zip)
cd cropguard_submission

# Initialize git
git init
git add .
git commit -m "feat: initial project setup — Phase 0 foundation"

# Create a dev branch (required by assessment)
git checkout -b dev
git add .
git commit -m "feat: add flutter app structure and screens"

# Go back to main
git checkout main

# Push to GitHub
# First create a NEW repo on github.com (click + → New repository → name it "cropguard")
git remote add origin https://github.com/YOUR_USERNAME/cropguard.git
git push -u origin main
git push -u origin dev

# Create a Pull Request on GitHub: dev → main (go to github.com/YOUR_USERNAME/cropguard/pulls)
```

---

## STEP 5 — Add secrets to GitHub (for CI/CD)

1. Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Add these secrets (New repository secret):

```
SUPABASE_URL           = https://YOUR.supabase.co
SUPABASE_ANON_KEY      = eyJ... (anon key, not service role)
BACKEND_URL            = https://YOUR-RAILWAY-URL.railway.app
RAILWAY_TOKEN          = (from Railway dashboard → Account → Tokens)
```

---

## STEP 6 — Build the Flutter APK

Make sure Flutter is installed: https://flutter.dev/docs/get-started/install

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Generate code (creates *.g.dart and *.freezed.dart files)
dart run build_runner build --delete-conflicting-outputs

# Build the APK
flutter build apk --debug \
  --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=BACKEND_URL=https://YOUR-RAILWAY-URL.railway.app
```

APK will be at: `flutter_app/build/app/outputs/flutter-apk/app-debug.apk`

Install it on an Android phone: plug in phone → `adb install app-debug.apk`  
Or send the APK file to your phone and open it (enable "Install unknown apps" in settings).

---

## STEP 7 — Test the app

1. Open CropGuard on your phone
2. Tap the green camera area → take/select a leaf photo
3. Tap "Diagnose" → should show disease name, confidence bar, treatments
4. Test OOD: try a selfie or photo of a wall → should show "Not a plant image"
5. Turn on airplane mode → take another photo → tap Diagnose
   - Should show "Offline" chip with "Pending" diagnosis
   - Turn airplane mode off → watch the sync indicator in top-right
6. Tap the mic button on a result → ask a question like "How do I treat this?"

---

## STEP 8 — What to submit

Email to indigenservices5@gmail.com with subject:
`Diksha Samrat Wagh — Real-Time Multimodal Field-Diagnostics Assistant`

Attach / include:
- [ ] GitHub repo link: `https://github.com/YOUR_USERNAME/cropguard`
- [ ] Live backend URL: `https://YOUR-RAILWAY-URL.railway.app/health`
- [ ] APK file (attach the .apk directly, or share via Google Drive)
- [ ] PROJECT_REPORT.md (attach as PDF — you can convert markdown to PDF at https://md2pdf.netlify.app)
- [ ] Architecture diagram (the one from earlier — screenshot it or export)
- [ ] PROMPTS.md (it's already in the repo, just mention it's there)

---

## STEP 9 — Before the live walkthrough

Be ready to explain:

1. **Why vector clocks instead of last-write-wins?**
   Answer: Last-write-wins loses data if two devices edit the same record offline. Vector clocks let us detect concurrent edits and merge intelligently. Each device tracks a `{device_id: timestamp}` map. On sync, we compare: if incoming > stored → accept, if stored > incoming → reject, if concurrent (neither dominates) → merge.

2. **How does OOD rejection work?**
   Answer: The Claude system prompt instructs it to first check if the image contains a plant. If not, it returns `is_plant: false` and the app shows the rejection banner. No separate classifier needed.

3. **What does calibrated confidence mean?**
   Answer: The system prompt has explicit bands — 0.9+ only for textbook-clear cases, 0.7-0.89 for likely, etc. This stops the model from always saying "95% confident" and forces honest uncertainty.

4. **How does the offline queue work?**
   Answer: Every diagnosis is written to SQLite first (always). If online, sync happens immediately after. If offline, `connectivity_plus` watches for network restore and triggers sync automatically.

5. **What would you add with more time?**
   Answer: Streaming TTS for lower latency, proper VAD for barge-in, PlantVillage eval for accuracy numbers, Supabase auth, image upload to Supabase Storage.

---

Good luck with the walkthrough!
