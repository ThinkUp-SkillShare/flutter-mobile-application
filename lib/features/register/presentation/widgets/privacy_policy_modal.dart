// lib/features/register/presentation/widgets/privacy_policy_modal.dart
import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';

class PrivacyPolicyModal extends StatelessWidget {
  const PrivacyPolicyModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundPrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textImportant,
                      fontFamily: 'Sarabun',
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.iconLessImportant,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildPrivacyContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Center(
          child: Text(
            'PRIVACY POLICY',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Arial',
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Last updated
        Center(
          child: Text(
            'Last updated December 01, 2025',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Arial',
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Content
        _buildSectionTitle('1. WHAT INFORMATION DO WE COLLECT?'),
        const SizedBox(height: 15),
        _buildSubtitle('Personal information you disclose to us'),
        const SizedBox(height: 10),
        _buildParagraph(
          'We collect personal information that you voluntarily provide to us when you register on the Services, express an interest in obtaining information about us or our products and Services, when you participate in activities on the Services, or otherwise when you contact us.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'Personal Information Provided by You. The personal information we collect may include:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('names'),
        _buildBulletPoint('email addresses'),
        _buildBulletPoint('usernames'),
        _buildBulletPoint('passwords'),
        _buildBulletPoint('mailing addresses'),
        const SizedBox(height: 15),
        _buildSubtitle('Sensitive Information'),
        const SizedBox(height: 10),
        _buildParagraph(
          'When necessary, with your consent or as otherwise permitted by applicable law, we process the following categories of sensitive information:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('information revealing race or ethnic origin'),
        _buildBulletPoint('information revealing political opinions'),
        const SizedBox(height: 20),
        _buildSectionTitle('2. HOW DO WE PROCESS YOUR INFORMATION?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'We process your information to provide, improve, and administer our Services, communicate with you, for security and fraud prevention, and to comply with law.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'We process your personal information for a variety of reasons, including:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('To facilitate account creation and authentication and otherwise manage user accounts.'),
        _buildBulletPoint('To save or protect an individual\'s vital interest.'),
        const SizedBox(height: 20),
        _buildSectionTitle('3. WHEN AND WITH WHOM DO WE SHARE YOUR PERSONAL INFORMATION?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'We may share information in specific situations and with specific third parties.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'We may need to share your personal information in the following situations:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('Business Transfers. We may share or transfer your information in connection with any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.'),
        const SizedBox(height: 20),
        _buildSectionTitle('4. DO WE USE COOKIES AND OTHER TRACKING TECHNOLOGIES?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'We may use cookies and similar tracking technologies (like web beacons and pixels) to gather information when you interact with our Services. Some online tracking technologies help us maintain the security of our Services and your account, prevent crashes, fix bugs, save your preferences, and assist with basic site functions.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('5. HOW LONG DO WE KEEP YOUR INFORMATION?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'We keep your information for as long as necessary to fulfill the purposes outlined in this Privacy Notice unless otherwise required by law.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'We will only keep your personal information for as long as it is necessary for the purposes set out in this Privacy Notice, unless a longer retention period is required or permitted by law.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('6. WHAT ARE YOUR PRIVACY RIGHTS?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'Depending on where you are located geographically, the applicable privacy law may mean you have certain rights regarding your personal information.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'In some regions, you have certain rights under applicable data protection laws. These may include the right to request access and obtain a copy of your personal information, to request rectification or erasure, to restrict the processing of your personal information, to data portability, and not to be subject to automated decision-making.',
        ),
        const SizedBox(height: 15),
        _buildSubtitle('Withdrawing your consent:'),
        const SizedBox(height: 10),
        _buildParagraph(
          'If we are relying on your consent to process your personal information, you have the right to withdraw your consent at any time.',
        ),
        const SizedBox(height: 15),
        _buildSubtitle('Account Information'),
        const SizedBox(height: 10),
        _buildParagraph(
          'If you would at any time like to review or change the information in your account or terminate your account, you can:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('Log in to your account settings and update your user account.'),
        const SizedBox(height: 15),
        _buildParagraph(
          'If you have questions or comments about your privacy rights, you may email us at skillshare@thinkup.com.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('7. DO UNITED STATES RESIDENTS HAVE SPECIFIC PRIVACY RIGHTS?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'If you are a resident of certain US states, you may have the right to request access to and receive details about the personal information we maintain about you and how we have processed it, correct inaccuracies, get a copy of, or delete your personal information.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('8. DO WE MAKE UPDATES TO THIS NOTICE?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'Yes, we will update this notice as necessary to stay compliant with relevant laws.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'We may update this Privacy Notice from time to time. The updated version will be indicated by an updated date at the top of this Privacy Notice.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('9. HOW CAN YOU CONTACT US ABOUT THIS NOTICE?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'If you have questions or comments about this notice, you may contact us by post at:',
        ),
        const SizedBox(height: 15),
        _buildParagraph('ThinkUp'),
        _buildParagraph('Magdalena, Lima, Lima, Peru'),
        _buildParagraph('Phone: 978777386'),
        _buildParagraph('Email: skillshare@thinkup.com'),
        const SizedBox(height: 20),
        _buildSectionTitle('10. HOW CAN YOU REVIEW, UPDATE, OR DELETE THE DATA WE COLLECT FROM YOU?'),
        const SizedBox(height: 15),
        _buildParagraph(
          'Based on the applicable laws of your country or state of residence in the US, you may have the right to request access to the personal information we collect from you, details about how we have processed it, correct inaccuracies, or delete your personal information.',
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Arial',
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Arial',
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF595959),
          fontFamily: 'Arial',
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF595959),
              fontFamily: 'Arial',
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF595959),
                fontFamily: 'Arial',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}