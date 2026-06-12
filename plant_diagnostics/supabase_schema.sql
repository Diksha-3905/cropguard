-- Run this in your Supabase SQL editor to set up the schema.
-- Go to: https://app.supabase.com → your project → SQL Editor

-- ── Diagnoses table ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS diagnoses (
  id                TEXT PRIMARY KEY,
  disease_name      TEXT,
  confidence        REAL,
  severity          TEXT,
  treatment_advice  TEXT,
  is_ood            BOOLEAN DEFAULT FALSE,
  image_url         TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at         TIMESTAMPTZ,
  vector_clock      JSONB DEFAULT '{}'::jsonb,
  sync_status       TEXT DEFAULT 'pending',
  user_id           UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Index for user history queries
CREATE INDEX IF NOT EXISTS diagnoses_user_id_idx ON diagnoses (user_id, created_at DESC);

-- ── Voice sessions table ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS voice_sessions (
  id              TEXT PRIMARY KEY,
  diagnosis_id    TEXT REFERENCES diagnoses(id) ON DELETE CASCADE,
  transcript      TEXT NOT NULL,
  response_text   TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- ── Row Level Security ────────────────────────────────────────
ALTER TABLE diagnoses ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_sessions ENABLE ROW LEVEL SECURITY;

-- Users can only see/modify their own records
CREATE POLICY "Users own their diagnoses" ON diagnoses
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own their voice sessions" ON voice_sessions
  FOR ALL USING (auth.uid() = user_id);

-- Service role can bypass RLS (used by backend sync endpoint)
-- This is automatic for the service role key.

-- ── Storage bucket for leaf images ───────────────────────────
-- Run via Supabase dashboard Storage > New bucket
-- Or via API:
-- INSERT INTO storage.buckets (id, name, public) VALUES ('leaf-images', 'leaf-images', false);
