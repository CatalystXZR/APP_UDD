class AppConstants {
  static const questionsPerTest = 7;
  static const optionsPerQuestion = 6;
  static const course = 'Cálculo Diferencial';
  static const content = 'Sucesiones y Límites';
  static const levels = ['Básico', 'Medio', 'Experto'];
  static const secondsPerQuestion = {
    'Básico': 60,
    'Medio': 90,
    'Experto': 180,
  };
}

class SupabaseEnv {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mkxdiqfhlmmnmfqkdvhh.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_tUw6KAvVYlZ3lkl3gYeV3A_Ff-a3LCD',
  );
}
