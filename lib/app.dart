import 'package:app_links/app_links.dart';
import 'package:ember/core/router/app_router.dart';
import 'package:ember/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Ember extends ConsumerStatefulWidget {
  const Ember({super.key});

  @override
  ConsumerState<Ember> createState() => _EmberState();
}

class _EmberState extends ConsumerState<Ember> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _listenForDeepLinks();
  }

  void _listenForDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) async {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read once — never watch. The router must never be recreated.
    final router = ref.read(appRouterProvider);

    return MaterialApp.router(
      title: 'Ember',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}