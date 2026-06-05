import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/auth/single_session_service.dart';
import 'package:gym_member_app/src/core/storage/shared_preferences_provider.dart';
import 'package:gym_member_app/src/core/supabase/supabase_client_provider.dart';

final singleSessionServiceProvider = Provider<SingleSessionService>((ref) {
  return SingleSessionService(
    ref.watch(supabaseClientProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
