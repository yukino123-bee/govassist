import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms & Conditions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'Last updated: October 2023\n\n'
              '1. Introduction\n'
              'Welcome to GovAssist. By using our application, you agree to these terms and conditions in full.\n\n'
              '2. Service Usage\n'
              'You must not use our app in any way that causes, or may cause, damage to the application or impairment of the availability or accessibility of the application.\n\n'
              '3. User Content\n'
              'In these terms and conditions, "your user content" means material (including without limitation text, images, and documents) that you submit to our application.\n\n'
              '4. Privacy\n'
              'We take your privacy seriously. Please review our Privacy Policy for details on how we handle your data.\n\n'
              '5. Modifications\n'
              'We may revise these terms and conditions from time-to-time. Revised terms and conditions will apply to the use of our application from the date of the publication of the revised terms on our application.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'Last updated: October 2023\n\n'
              '1. Data Collection\n'
              'We collect personal data that you provide directly to us, including your name, email address, physical address, date of birth, and any valid ID documents you upload.\n\n'
              '2. Data Usage\n'
              'We use the information we collect to operate, maintain, and provide the features and functionality of the Service, as well as to communicate directly with you.\n\n'
              '3. Data Security\n'
              'We implement appropriate security measures to protect against unauthorized access, alteration, disclosure, or destruction of your personal information, username, password, transaction information and data stored on our app.\n\n'
              '4. Data Sharing\n'
              'We do not sell, trade, or rent users personal identification information to others. We may share generic aggregated demographic information not linked to any personal identification information regarding visitors and users with our business partners.\n\n'
              '5. Contact Us\n'
              'If you have any questions about this Privacy Policy, the practices of this site, or your dealings with this site, please contact us.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
