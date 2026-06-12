# PROMPTS.md — Raw Prompt Log

> Every prompt I personally wrote to AI tools, in order, verbatim.
> Committed incrementally alongside code (not added at the end).
> One-line note per prompt: what I was trying to do and whether it worked.

---

## Phase 0 — Project setup

**Prompt 1** — to Claude (architecture planning)
```
I need to build a Flutter + FastAPI plant disease diagnostics app with offline-first sync and voice Q&A.
Help me design the system architecture. Key requirements:
- Camera captures leaf → disease classification with confidence score
- Reject non-plant images (OOD detection)
- Voice follow-up Q&A with STT/TTS
- Offline queue + conflict-resolving sync (not last-write-wins)
What's the best stack and folder structure?
```
*Result: Got a solid architecture. Chose Flutter + FastAPI on Railway + Supabase + Claude Sonnet + Deepgram + ElevenLabs. ✅*

---

**Prompt 2** — to Claude (Drift schema)
```
Write a Drift (dart) database schema for:
1. A diagnoses table with: id, imageLocalPath, diseaseName, confidence, severity, treatmentAdvice, isOod, status (pending/synced/failed), createdAt, syncedAt, vectorClockJson (TEXT storing JSON map)
2. A voice_sessions table

Include a singleton DatabaseService class.
```
*Result: Good output. Had to adjust the companion classes manually for the upsert logic. ✅*

---

**Prompt 3** — to Claude (vector clock logic)
```
Implement vector clock conflict resolution in Python for a sync endpoint.
Rules:
- Compare incoming vector clock vs stored clock
- If incoming > stored: accept
- If stored > incoming: reject (return server version)
- If concurrent: merge (max of each key), server's diagnosis fields win
Make it idempotent — same id synced twice should be safe.
```
*Result: Correct logic. Added edge case for missing clock keys (treat as 0). ✅*

---

## Phase 1 — Vision diagnosis

**Prompt 4** — to Claude (system prompt for diagnosis)
```
Write a system prompt for Claude Sonnet to act as a plant pathologist.
Requirements:
- First check if image is a plant (OOD rejection)
- Return structured JSON only
- Confidence must be CALIBRATED, not inflated. Give guidelines:
  0.9+ = textbook clear, 0.7-0.89 = likely, 0.5-0.69 = ambiguous, <0.5 = low
- Treatments must be grounded agronomic practices
- Include severity (mild/moderate/severe)
- Include a disclaimer
```
*Result: Good prompt. Needed to add the "RESPOND ONLY WITH THIS JSON" instruction explicitly — first version sometimes added markdown prose around the JSON. ✅*

---

**Prompt 5** — to Claude (OOD rejection test)
```
How do I test OOD rejection without a real model call? Give me 3 example images (described)
that should be rejected and 3 that should be accepted, and what the model should return for each.
```
*Result: Useful for writing unit tests. ✅*

---

## Phase 2 — Voice

**Prompt 6** — to Claude (voice pipeline design)
```
I'm implementing barge-in for a voice Q&A system. The user can interrupt TTS playback
by speaking. In Flutter, how do I:
1. Detect microphone input while AudioPlayer is playing
2. Stop playback immediately when audio energy crosses a threshold
3. Start recording the new utterance

I'm using the `record` package for recording and `just_audio` for playback.
```
*Result: Got a workable approach using the record stream + amplitude monitoring. The actual amplitude-based VAD needs more tuning in a real build. ✅ (simplified in code — full VAD would be a separate effort)*

---

**Prompt 7** — to Claude (ElevenLabs TTS latency)
```
What's the fastest way to get TTS audio from ElevenLabs with low latency?
I need p95 < 2 seconds for voice responses in a mobile app.
Options: streaming vs full response, model choice, voice settings?
```
*Result: Recommended eleven_turbo_v2 model + streaming. Streaming not implemented in v1 of this code — noted as known limitation. ⚠️*

---

## Phase 3 — Offline sync

**Prompt 8** — to Claude (connectivity detection in Flutter)
```
In Flutter, using connectivity_plus, how do I:
1. Check current connection state
2. Listen for connectivity changes
3. Trigger a sync when connectivity is restored
4. Handle the case where connectivity_plus says we're connected but we're actually behind a captive portal
```
*Result: Good code. Captive portal detection is not implemented — noted as known limitation. ✅*

---

**Prompt 9** — to myself (debugging Drift generated code)
```
The Drift-generated companion class doesn't have a vectorClockJson field. 
Check the table definition — is the column name mismatched?
```
*Result: Found it — column was named vectorClock in one place and vectorClockJson in another. Fixed. ✅*

---

## Phase 4 — Evaluation (documented, not fully implemented)

**Prompt 10** — to Claude (PlantVillage eval approach)
```
I want to evaluate my plant disease classifier on PlantVillage dataset samples.
What's the right approach to measure:
1. Precision/recall per disease class
2. OOD rejection accuracy (FPR on non-plant images)
3. Confidence calibration (ECE — Expected Calibration Error)

Give me a Python script outline that I would run offline.
```
*Result: Got a solid eval framework outline. Not implemented in the 48h submission — documented in report as "what I'd build next." ✅*

---

*This log will be updated incrementally as development continues.*
