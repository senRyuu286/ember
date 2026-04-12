import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ember/core/theme/app_colors.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  static const Color _primaryOrange = AppColors.primary;

  // Add new entries at the top of this list as the app grows.
  static const List<_ChangelogEntry> _entries = [
    _ChangelogEntry(
      version: '1.0.0',
      date: 'April 11, 2026',
      isLatest: true,
      changes: [
        _Change(type: _ChangeType.added, description: 'User authentication with email and password.'),
        _Change(type: _ChangeType.added, description: 'Profile setup with username, bio, and avatar selection.'),
        _Change(type: _ChangeType.added, description: 'Profile screen with editable bio, fitness level, and preferences.'),
        _Change(type: _ChangeType.added, description: 'Light and dark theme support driven by user preference.'),
        _Change(type: _ChangeType.added, description: '12 custom Ember-themed avatars to choose from.'),
        _Change(type: _ChangeType.added, description: 'Offline-first profile caching with local SQLite storage.'),
        _Change(type: _ChangeType.added, description: 'Terms and Conditions and Privacy Policy screens.'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── App bar ──
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "What's New",
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Changelog',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  itemCount: _entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    return _ChangelogCard(entry: _entries[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

enum _ChangeType { added, changed, fixed, removed }

class _Change {
  const _Change({required this.type, required this.description});
  final _ChangeType type;
  final String description;
}

class _ChangelogEntry {
  const _ChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
    this.isLatest = false,
  });
  final String version;
  final String date;
  final List<_Change> changes;
  final bool isLatest;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ChangelogCard extends StatelessWidget {
  const _ChangelogCard({required this.entry});
  final _ChangelogEntry entry;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: entry.isLatest
              ? _primaryOrange.withValues(alpha: 0.4)
              : colorScheme.outline,
          width: entry.isLatest ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Version header ──
          Row(
            children: [
              Text(
                'v${entry.version}',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 10),
              if (entry.isLatest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryOrange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Latest',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.date,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),

          // ── Change items ──
          ...entry.changes.map((change) => _ChangeItem(change: change)),
        ],
      ),
    );
  }
}

class _ChangeItem extends StatelessWidget {
  const _ChangeItem({required this.change});
  final _Change change;

  Color _typeColor(_ChangeType type) {
    switch (type) {
      case _ChangeType.added:
        return AppColors.success;
      case _ChangeType.changed:
        return AppColors.accent;
      case _ChangeType.fixed:
        return AppColors.primary;
      case _ChangeType.removed:
        return AppColors.secondary;
    }
  }

  String _typeLabel(_ChangeType type) {
    switch (type) {
      case _ChangeType.added:
        return 'NEW';
      case _ChangeType.changed:
        return 'UPD';
      case _ChangeType.fixed:
        return 'FIX';
      case _ChangeType.removed:
        return 'REM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _typeColor(change.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _typeLabel(change.type),
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              change.description,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}