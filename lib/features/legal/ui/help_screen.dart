import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/entities/legal_entities.dart';
import '../providers/legal_provider.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  static const Color _primaryOrange = AppColors.primary;

  Future<void> _launchEmail({
    required String supportEmail,
    required String subject,
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportEmail = ref.watch(supportEmailProvider);
    final appVersion = ref.watch(legalAppVersionProvider);
    final faqs = ref.watch(legalFaqsProvider);

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
                        'Help & Support',
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
                        'Support',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero banner ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryOrange.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _primaryOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                color: _primaryOrange,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How can we help?',
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: 16,
                                      color: AppColors.darkTextPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Browse the FAQ or reach out directly. We typically respond within 48 hours.',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppColors.darkTextSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── FAQ section ──
                      _SectionLabel(
                        icon: Icons.help_outline_rounded,
                        label: 'Frequently Asked Questions',
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            children: faqs
                                .asMap()
                                .entries
                                .map(
                                  (entry) => _FaqTile(
                                    item: entry.value,
                                    showDivider:
                                        entry.key < faqs.length - 1,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Contact actions ──
                      _SectionLabel(
                        icon: Icons.contact_support_rounded,
                        label: 'Get in Touch',
                      ),
                      const SizedBox(height: 12),

                      // Report a bug
                      _ContactCard(
                        icon: Icons.bug_report_outlined,
                        title: 'Report a Bug',
                        subtitle:
                            'Found something broken? Let us know and we\'ll get it fixed.',
                        buttonLabel: 'Send Bug Report',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _launchEmail(
                            supportEmail: supportEmail,
                            subject: 'Bug Report — Ember v$appVersion',
                            body:
                                'Describe the bug:\n\n'
                                'Steps to reproduce:\n1.\n2.\n3.\n\n'
                                'Expected behavior:\n\n'
                                'Actual behavior:\n\n'
                                'Device and OS:\n\n'
                                'App version: $appVersion',
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Contact us
                      _ContactCard(
                        icon: Icons.mail_outline_rounded,
                        title: 'Contact Us',
                        subtitle:
                            'Have a question that\'s not in the FAQ? Send us an email.',
                        buttonLabel: 'Send Email',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _launchEmail(
                            supportEmail: supportEmail,
                            subject: 'Ember Support Request',
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Footer ──
                      Center(
                        child: Text(
                          'Ember v$appVersion · Made with 🔥 by senRyuu286',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
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
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _primaryOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 17, color: _primaryOrange),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item, required this.showDivider});
  final LegalFaqItem item;
  final bool showDivider;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _iconTurn;

  static const Color _primaryOrange = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurn = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                RotationTransition(
                  turns: _iconTurn,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: _expanded
                        ? _primaryOrange
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Text(
              widget.item.answer,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
            indent: 18,
            endIndent: 18,
          ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryOrange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      buttonLabel,
                      style: textTheme.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}