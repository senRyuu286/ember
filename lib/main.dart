import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final appLinks = AppLinks();
  final initialLink = await appLinks.getInitialLink();
  if (initialLink != null) {
    await Supabase.instance.client.auth.getSessionFromUrl(initialLink);
  }

  runApp(
    const ProviderScope(
      child: Ember(),
    ),
  );
}