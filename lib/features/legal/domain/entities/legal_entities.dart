enum LegalChangelogChangeType { added, changed, fixed, removed }

class LegalFaqItem {
  final String question;
  final String answer;

  const LegalFaqItem({required this.question, required this.answer});
}

class LegalChangelogChange {
  final LegalChangelogChangeType type;
  final String description;

  const LegalChangelogChange({
    required this.type,
    required this.description,
  });
}

class LegalChangelogEntry {
  final String version;
  final String date;
  final List<LegalChangelogChange> changes;
  final bool isLatest;

  const LegalChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
    this.isLatest = false,
  });
}
