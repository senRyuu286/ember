import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ember/core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Definitions',
                        content: const [
                          _BulletItem(
                            term: 'Account',
                            definition:
                                'A unique account created for You to access the Service.',
                          ),
                          _BulletItem(
                            term: 'Application',
                            definition:
                                'Refers to Ember, the software program provided by the Company.',
                          ),
                          _BulletItem(
                            term: 'Company',
                            definition:
                                'Refers to senRyuu286, the individual developer operating Ember, based in the Philippines.',
                          ),
                          _BulletItem(
                            term: 'Personal Data',
                            definition:
                                'Any information that relates to an identified or identifiable individual.',
                          ),
                          _BulletItem(
                            term: 'Service',
                            definition: 'Refers to the Application.',
                          ),
                          _BulletItem(
                            term: 'Service Provider',
                            definition:
                                'Any third-party entity that processes data on behalf of the Company — in this case, Supabase.',
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
                        title: 'What Data We Collect',
                        body:
                            'When You use Ember, We collect and store the following data:\n\n• Your email address, used solely for account authentication.\n• Your profile data: username, avatar selection, bio, fitness level, and preferences You set within the app.\n• Your fitness data: workout sessions, logged sets, reps, weights, routines, and workout plans that You create or log.\n• Device and usage metadata collected automatically by Supabase (such as IP address and timestamps) for service monitoring and security purposes.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'How We Use Your Data',
                        body:
                            'We use Your data for the following purposes:\n\n• To create and maintain Your account and provide the core features of the Service.\n• To sync Your fitness data across devices when You are signed in.\n• To send You security-related communications such as password reset emails when requested.\n• To analyze aggregate usage patterns to improve the Service. We do not analyze Your individual workout data for any purpose beyond providing the Service to You.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Data Storage and Third-Party Providers',
                        body:
                            'All Your data is stored on Supabase, a third-party backend infrastructure provider. Supabase stores data on secure servers and applies industry-standard security practices including Row Level Security, which ensures that Your data is only accessible to You.\n\nEmber also stores a local cache of Your profile and workout data on Your device using SQLite (via the Drift library). This local cache is used to allow the app to function without an internet connection.\n\nSupabase Privacy Policy: https://supabase.com/privacy\n\nWe do not share, sell, rent, or trade Your Personal Data with any other third parties.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Data Retention',
                        body:
                            'We retain Your Personal Data for as long as Your account remains active. If You request deletion of Your account, We will remove Your Personal Data from Our systems within a reasonable time, up to a maximum of 30 days, unless retention is required by applicable law.\n\nNote: A self-service account deletion feature is planned for a future update. Until it is available, You may contact us at justinramas12@outlook.com to request deletion of Your account and associated data.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Your Rights Over Your Data',
                        body:
                            'You have the right to:\n\n• Access the Personal Data We hold about You.\n• Correct any inaccurate profile data directly within the app.\n• Request deletion of Your Personal Data by contacting us.\n• Withdraw consent at any time by ceasing to use the Service and requesting account deletion.\n\nFor EEA and UK residents: You have additional rights under the GDPR including the right to data portability and the right to lodge a complaint with a supervisory authority.\n\nFor California residents: We do not sell Your Personal Data. You have the right to know what data we collect, request its deletion, and not receive discriminatory treatment for exercising Your privacy rights.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Disclosure of Your Data',
                        body:
                            'We may disclose Your Personal Data only in the following limited circumstances:\n\n• To comply with a legal obligation or valid law enforcement request.\n• To protect and defend the rights or property of the Company.\n• To prevent or investigate possible wrongdoing in connection with the Service.\n• In the event of a business transfer, merger, or acquisition involving the Company.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Security',
                        body:
                            'We take the security of Your Personal Data seriously. All data transmitted between the app and Supabase is encrypted in transit using TLS. Supabase applies Row Level Security policies that ensure no user can access another user\'s data.\n\nHowever, no method of transmission over the internet or electronic storage is 100% secure. We cannot guarantee absolute security of Your data, and You use the Service at Your own risk.',
                      ),
                      _buildLimitationSection(context, colorScheme, textTheme),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: "Children's Privacy",
                        body:
                            'Ember is not specifically directed at children under the age of 13. We do not require age verification during account creation, and We cannot definitively verify the age of Our users.\n\nBy using the Service, You represent that You are using it voluntarily and responsibly. If You are a parent or guardian and believe Your child has provided Us with Personal Data without Your consent, please contact us immediately at justinramas12@outlook.com and We will take steps to remove that information.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Changes to This Policy',
                        body:
                            'We may update this Privacy Policy from time to time. Any changes will be reflected by updating the "Last updated" date at the top of this document. Your continued use of the Service after any changes constitutes Your acceptance of the updated policy.',
                      ),
                      _buildSection(
                        context,
                        colorScheme,
                        textTheme,
                        title: 'Contact Us',
                        body:
                            'If you have any questions, concerns, or requests regarding this Privacy Policy or Your Personal Data, please contact us at:\n\njustinramas12@outlook.com',
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
              'Privacy Policy',
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        'This Privacy Policy describes how senRyuu286 ("We", "Us", "Our") collects, uses, and protects the Personal Data of users of the Ember application. By using the Service, You agree to the collection and use of information in accordance with this policy.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.6,
          fontSize: 13,
        ),
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

  Widget _buildLimitationSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Limitation of Liability'),
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
            child: Text(
              'TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL THE COMPANY BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES WHATSOEVER, INCLUDING BUT NOT LIMITED TO DAMAGES FOR LOSS OF DATA, PRIVACY BREACHES, PERSONAL INJURY, OR PROPERTY DAMAGE ARISING OUT OF YOUR USE OF THE APP. THE SERVICE IS PROVIDED "AS IS" AND WITHOUT WARRANTY OF ANY KIND.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                height: 1.6,
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
// Shared sub-widgets (duplicated here to keep files self-contained)
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