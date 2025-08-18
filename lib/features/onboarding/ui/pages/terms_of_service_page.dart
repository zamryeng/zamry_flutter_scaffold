import 'package:flutter/material.dart';

import '../../../../core/presentation/presentation.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key, required this.onAgree, required this.onCancel});

  final VoidCallback onAgree;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 14),
          child: AppIconButton(
            onPressed: onCancel,
            label: 'Back',
            child: const Icon(Icons.arrow_back),
          ),
        ),
        title: Text('Terms of Service', style: context.styles.heading20Semibold),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Summary title
            Text('Summary', style: context.styles.heading20Bold),

            const SizedBox(height: 24),

            // Terms content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermsSection(
                      context: context,
                      title: 'Service Usage',
                      content:
                          'By using this USSD utility service, you agree to allow the app to access your device\'s USSD functionality to perform financial transactions and account inquiries.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      context: context,
                      title: 'Data Privacy',
                      content:
                          'We respect your privacy and will not store or transmit your personal financial information. All USSD operations are performed locally on your device.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      context: context,
                      title: 'Permissions',
                      content:
                          'The app requires SMS, Call, and Accessibility permissions to function properly. These permissions are used solely for USSD operations and service functionality.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      context: context,
                      title: 'Liability',
                      content:
                          'You are responsible for all transactions performed through this service. Please ensure you review all transaction details before confirming.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      context: context,
                      title: 'Service Availability',
                      content:
                          'Service availability depends on your network provider and may be subject to network conditions and provider policies.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: 'Cancel',
                    onPressed: onCancel,
                    view: 'TermsOfServicePage',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton.primary(
                    label: 'Agree to ToS',
                    onPressed: onAgree,
                    view: 'TermsOfServicePage',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.styles.body16SemiBold.copyWith(color: context.colors.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: context.styles.body14Regular.copyWith(color: context.colors.grey700, height: 1.5),
        ),
      ],
    );
  }
}
