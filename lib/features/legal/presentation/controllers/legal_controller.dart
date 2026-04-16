import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/legal_content.dart';
import '../../domain/entities/legal_entities.dart';

final supportEmailProvider = Provider<String>((ref) {
  return LegalContent.supportEmail;
});

final legalAppVersionProvider = Provider<String>((ref) {
  return LegalContent.appVersion;
});

final legalFaqsProvider = Provider<List<LegalFaqItem>>((ref) {
  return LegalContent.faqs;
});

final legalChangelogEntriesProvider = Provider<List<LegalChangelogEntry>>((ref) {
  return LegalContent.changelogEntries;
});
