import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/legal_entities.dart';
import '../presentation/controllers/legal_controller.dart' as controller;

final supportEmailProvider = controller.supportEmailProvider;

final legalAppVersionProvider = controller.legalAppVersionProvider;

final legalFaqsProvider = Provider<List<LegalFaqItem>>((ref) {
  return ref.watch(controller.legalFaqsProvider);
});

final legalChangelogEntriesProvider = Provider<List<LegalChangelogEntry>>((ref) {
  return ref.watch(controller.legalChangelogEntriesProvider);
});
