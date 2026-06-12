/// Environment configuration — loaded from --dart-define at build time.
/// Never commit real keys. See .env.example in root.
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );
  static const backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://your-worker.railway.app',
  );
}
