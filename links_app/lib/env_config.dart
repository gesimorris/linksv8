class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    '',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    '',
    defaultValue: '',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}