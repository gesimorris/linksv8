class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'https://kiqcfijttxuxbdoomslw.supabase.co',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpcWNmaWp0dHh1eGJkb29tc2x3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwMDQwODIsImV4cCI6MjA5MDU4MDA4Mn0.-cTQZO8ymU3wOvLKXF6PGzV4UeJ4sU9WBdA24uGqGtc',
    defaultValue: '',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}