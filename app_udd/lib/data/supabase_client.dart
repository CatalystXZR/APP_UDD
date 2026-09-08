import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';

Future<bool> initSupabase() async {
  try {
    await Supabase.initialize(url: SupabaseEnv.url, publishableKey: SupabaseEnv.publishableKey);
    return true;
  } catch (_) {
    return false;
  }
}

SupabaseClient get supabase => Supabase.instance.client;

bool get supabaseReady {
  try {
    Supabase.instance.client;
    return true;
  } catch (_) {
    return false;
  }
}
