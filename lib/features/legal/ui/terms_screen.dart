import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ember/core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const Color _primaryOrange = AppColors.primary;

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
              _buildAppBar(context, colorScheme, textTheme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLastUpdated(context, colorScheme, textTheme),
                      _buildIntro(context, colorScheme, textTheme),
                      _buildWarningBanner(context, colorScheme, textTheme),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Definitions',
                        content: const [
                          _BulletItem(
                            term: 'Application',
                            definition:
                                'The software program downloaded by You on any electronic device, named Ember.',
                          ),
                          _BulletItem(
                            term: 'Company',
                            definition:
                                'Referred to as "We", "Us", or "Our" — refers to senRyuu286, operating Ember as an individual developer based in the Philippines.',
                          ),
                          _BulletItem(
                            term: 'Service',
                            definition: 'Refers to the Application.',
                          ),
                          _BulletItem(
                            term: 'User-Generated Content',
                            definition:
                                'Workout routines, customized plans, and any fitness data logged or created by You within the Application.',
                          ),
                          _BulletItem(
                            term: 'You',
                            definition:
                                'The individual accessing or using the Service.',
                          ),
                        ],
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Acknowledgment',
                        body:
                            'These Terms and Conditions govern your use of this Service and form a binding agreement between You and the Company. By accessing or using the Service, You agree to be bound by these Terms.\n\nEmber is not actively marketed or distributed through any public app store. By obtaining and using the Service through any means, You acknowledge that You are doing so voluntarily and that You assume all risks — physical and digital — associated with its use, regardless of Your age.\n\nYou are solely responsible for ensuring that your use of the Service is appropriate given your personal health, physical condition, and applicable local laws.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'User Accounts',
                        body:
                            'The Service allows You to create an account to save and sync Your data. When creating an account, You must provide accurate and complete information. You are entirely responsible for safeguarding Your password and for all activities that occur under Your account.\n\nThe Company will not be liable for any loss or damage arising from Your failure to comply with this obligation.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'User-Generated Content and Routines',
                        body:
                            'The Service allows You to create, organize, and manage custom workout routines and plans. You are entirely responsible for the content of, and any physical harm resulting from, the routines You create or follow.\n\nEmber is a digital notepad and timer platform. We do not endorse, verify, certify, or guarantee the medical safety, physiological effectiveness, suitability, or accuracy of any user-created workouts or the pre-loaded exercise library. Nothing in the Application constitutes medical or professional fitness advice. Consult a qualified healthcare or fitness professional before beginning any exercise program.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Intellectual Property and AI-Generated Assets',
                        body:
                            'The Service utilizes visual and textual assets that have been generated by Artificial Intelligence. The Company does not claim exclusive proprietary ownership or strict copyright over these specific AI-generated assets.\n\nHowever, the compiled software, codebase, architecture, and overall design and structure of the Application remain the exclusive property of senRyuu286. You may not copy, modify, distribute, or reverse-engineer any part of the Application.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Termination',
                        body:
                            'We reserve the right to terminate or suspend Your account and wipe Your stored data immediately, without prior notice or liability, for any reason whatsoever, at Our sole discretion. Upon termination, Your right to use the Service will cease immediately.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: '"AS IS" and "AS AVAILABLE" Disclaimer',
                        body:
                            'The Service is provided to You "AS IS" and "AS AVAILABLE" with all faults and defects and without warranty of any kind. The Company expressly disclaims all warranties, whether express, implied, statutory, or otherwise, including but not limited to any implied warranties of merchantability, fitness for a particular purpose, and non-infringement.\n\nThe Company makes no representation or warranty that the Service will operate without interruption, be error-free, meet any performance standards, or that Your User-Generated Content (workout history, logged sets, routines) will not be accidentally lost, deleted, or corrupted.',
                      ),
                      _buildLiabilitySection(context, colorScheme, textTheme),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Governing Law',
                        body:
                            'These Terms and Your use of the Service shall be governed by and construed in accordance with the laws of the Republic of the Philippines, excluding its conflict of law rules. Any disputes arising under these Terms shall be subject to the exclusive jurisdiction of the courts of the Philippines.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Changes to These Terms',
                        body:
                            'We reserve the right, at Our sole discretion, to modify or replace these Terms at any time. Changes will be indicated by updating the "Last updated" date at the top of this document. By continuing to access or use the Service after revisions become effective, You agree to be bound by the revised Terms.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Contact Us',
                        body:
                            'If you have any questions about these Terms and Conditions, you may contact us at:\n\njustinramas12@outlook.com',
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

  Widget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
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
              'Terms and Conditions',
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Legal',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 13,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            'Last updated: April 11, 2026',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        'Please read these Terms and Conditions carefully before using Ember. By using the Service, You accept and agree to be bound by these Terms. If You disagree with any part of these Terms, You must discontinue use of the Service immediately.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.6,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildWarningBanner(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _primaryOrange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: _primaryOrange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ember is a fitness tracking tool only. It does not provide medical advice. You use it entirely at your own risk. The developer, senRyuu286, assumes no liability for any injury, data loss, or harm arising from your use of this app.',
              style: textTheme.bodySmall?.copyWith(
                color: _primaryOrange,
                height: 1.5,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required String title,
    String? body,
    List<Widget>? content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title),
          const SizedBox(height: 12),
          if (body != null)
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.65,
                fontSize: 13,
              ),
            ),
          if (content != null) ...content,
        ],
      ),
    );
  }

  Widget _buildLiabilitySection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Limitation of Liability — USE AT YOUR OWN RISK'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU EXPRESSLY UNDERSTAND AND AGREE THAT THE COMPANY SHALL NOT BE LIABLE FOR ABSOLUTELY ANYTHING ARISING FROM YOUR USE OF THE APP.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    height: 1.55,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL THE COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING WITHOUT LIMITATION:',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _liabilityBullet(
                  context,
                  colorScheme,
                  textTheme,
                  'Personal injury, physical harm, or death resulting from lifting weights or engaging in any exercise routine tracked or suggested in the app.',
                ),
                _liabilityBullet(
                  context,
                  colorScheme,
                  textTheme,
                  'Loss of data, workout history, or User-Generated Content due to server failure, software bugs, or any other cause.',
                ),
                _liabilityBullet(
                  context,
                  colorScheme,
                  textTheme,
                  'Device damage, software corruption, or any other technical harm.',
                ),
                _liabilityBullet(
                  context,
                  colorScheme,
                  textTheme,
                  'Any harm arising from reliance on the pre-loaded exercise library or any in-app content.',
                ),
                const SizedBox(height: 12),
                Text(
                  'EMBER IS STRICTLY A DIGITAL TRACKING TOOL. YOU ASSUME 100% OF THE RISK WHEN ENGAGING IN ANY PHYSICAL ACTIVITY. YOUR EXCLUSIVE REMEDY FOR ANY DISSATISFACTION OR DATA LOSS IS TO STOP USING THE SERVICE.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    height: 1.55,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liabilityBullet(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.55,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
          ),
        ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.term, required this.definition});
  final String term;
  final String definition;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$term — ',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  TextSpan(
                    text: definition,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}