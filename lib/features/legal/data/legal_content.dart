import '../domain/entities/legal_entities.dart';

class LegalContent {
  LegalContent._();

  static const String supportEmail = 'justinramas12@outlook.com';
  static const String appVersion = '1.0.0';

  static const List<LegalFaqItem> faqs = [
    LegalFaqItem(
      question: 'How do I reset my password?',
      answer:
          'On the Sign In screen, tap "Forgot Password" and enter your email address. You will receive a password reset link in your inbox. Check your spam folder if it does not arrive within a few minutes.',
    ),
    LegalFaqItem(
      question: 'My workout data is not syncing. What do I do?',
      answer:
          'Ember syncs your data with Supabase whenever you have an internet connection. If data is not syncing, check your internet connection and try closing and reopening the app. Your data is also cached locally on your device, so nothing is lost while offline.',
    ),
    LegalFaqItem(
      question: 'Can I use Ember without internet?',
      answer:
          'Yes. Ember caches your profile and workout data locally on your device using SQLite. You can log workouts and view your history without an internet connection. Your data will sync to the cloud the next time you are online.',
    ),
    LegalFaqItem(
      question: 'How do I delete my account?',
      answer:
          'A self-service account deletion feature is coming in a future update. In the meantime, send an email to $supportEmail with the subject "Account Deletion Request" and include your registered email address. We will delete your account and all associated data within 30 days.',
    ),
    LegalFaqItem(
      question: 'Why did I lose my data after logging out?',
      answer:
          'When you log out, Ember clears its local cache to protect your data on shared devices. Your data is safely stored in the cloud and will be restored the next time you log in with your account.',
    ),
    LegalFaqItem(
      question: 'What does Ember XP do?',
      answer:
          'Ember XP is earned every time you complete a workout session. Each exercise has its own XP value, and your total XP reflects your overall training volume over time. More XP mechanics and rewards are planned for future updates.',
    ),
    LegalFaqItem(
      question: 'Can I share my workout routines with friends?',
      answer:
          'Routine sharing between friends is a planned feature and is not yet available in this version of Ember. Stay tuned for future updates.',
    ),
  ];

  static const List<LegalChangelogEntry> changelogEntries = [
    LegalChangelogEntry(
      version: '1.0.0',
      date: 'April 11, 2026',
      isLatest: true,
      changes: [
        LegalChangelogChange(
          type: LegalChangelogChangeType.added,
          description: 'User authentication with email and password.',
        ),
        LegalChangelogChange(
          type: LegalChangelogChangeType.added,
          description: 'Profile setup with username, bio, and avatar selection.',
        ),
        LegalChangelogChange(
          type: LegalChangelogChangeType.added,
          description: 'Profile screen with editable bio, fitness level, and preferences.',
        ),
        LegalChangelogChange(
          type: LegalChangelogChangeType.added,
          description: 'Light and dark theme support driven by user preference.',
        ),
        LegalChangelogChange(
          type: LegalChangelogChangeType.added,
          description: '12 custom Ember-themed avatars to choose from.',
        ),
        LegalChangelogChange(
          type: LegalChangelogChangeType.added,
          description: 'Offline-first profile caching with local SQLite storage.',
        ),
        LegalChangelogChange(
          type: LegalChangelogChangeType.added,
          description: 'Terms and Conditions and Privacy Policy screens.',
        ),
      ],
    ),
  ];
}
