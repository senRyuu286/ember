import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/profile/data/profile_models.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

final themeModeProvider = Provider<ThemeMode>((ref) {
  final profileAsync = ref.watch(userProfileProvider);

  final preference = profileAsync.asData?.value?.theme ?? ThemePreference.system;

  switch (preference) {
    case ThemePreference.light:
      return ThemeMode.light;
    case ThemePreference.dark:
      return ThemeMode.dark;
    case ThemePreference.system:
      return ThemeMode.system;
  }
});