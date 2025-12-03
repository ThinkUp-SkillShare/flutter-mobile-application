// lib/features/register/presentation/widgets/terms_and_conditions_modal.dart
import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';

class TermsAndConditionsModal extends StatelessWidget {
  const TermsAndConditionsModal({super.key});

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
                    'Terms and Conditions',
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
                  child: _buildTermsContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Center(
          child: Text(
            'TERMS AND CONDITIONS',
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
        _buildSectionTitle('1. AGREEMENT TO OUR LEGAL TERMS'),
        const SizedBox(height: 15),
        _buildParagraph(
          'We are ThinkUp ("Company," "we," "us," "our"), a company registered in Peru at Magdalena, Lima.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'We operate the mobile application SkillShare (the "App"), as well as any other related products and services that refer or link to these legal terms (the "Legal Terms") (collectively, the "Services").',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'SkillShare is a social app created by ThinkUp that connects students with similar academic interests to form dynamic study groups. It allows users to create or join groups by subject, chat and make video calls, as well as share notes and resources, facilitating more effective and less isolated collaborative learning.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'You can contact us by phone at 978777386, email at skillshare@thinkup.com, or by mail to Magdalena, Lima, Lima, Peru.',
        ),
        const SizedBox(height: 15),
        _buildParagraph(
          'These Legal Terms constitute a legally binding agreement made between you, whether personally or on behalf of an entity ("you"), and ThinkUp, concerning your access to and use of the Services. You agree that by accessing the Services, you have read, understood, and agreed to be bound by all of these Legal Terms. IF YOU DO NOT AGREE WITH ALL OF THESE LEGAL TERMS, THEN YOU ARE EXPRESSLY PROHIBITED FROM USING THE SERVICES AND YOU MUST DISCONTINUE USE IMMEDIATELY.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('2. INTELLECTUAL PROPERTY RIGHTS'),
        const SizedBox(height: 15),
        _buildSubtitle('Our intellectual property'),
        const SizedBox(height: 10),
        _buildParagraph(
          'We are the owner or the licensee of all intellectual property rights in our Services, including all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics in the Services (collectively, the "Content"), as well as the trademarks, service marks, and logos contained therein (the "Marks").',
        ),
        const SizedBox(height: 20),
        _buildSubtitle('Your use of our Services'),
        const SizedBox(height: 10),
        _buildParagraph(
          'Subject to your compliance with these Legal Terms, we grant you a non-exclusive, non-transferable, revocable license to:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('access the Services; and'),
        _buildBulletPoint('download or print a copy of any portion of the Content to which you have properly gained access,'),
        const SizedBox(height: 10),
        _buildParagraph(
          'solely for your personal, non-commercial use or internal business purpose.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('3. USER REPRESENTATIONS'),
        const SizedBox(height: 15),
        _buildParagraph(
          'By using the Services, you represent and warrant that:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('all registration information you submit will be true, accurate, current, and complete;'),
        _buildBulletPoint('you will maintain the accuracy of such information and promptly update such registration information as necessary;'),
        _buildBulletPoint('you have the legal capacity and you agree to comply with these Legal Terms;'),
        _buildBulletPoint('you are not a minor in the jurisdiction in which you reside, or if a minor, you have received parental permission to use the Services;'),
        _buildBulletPoint('you will not access the Services through automated or non-human means;'),
        _buildBulletPoint('you will not use the Services for any illegal or unauthorized purpose;'),
        _buildBulletPoint('your use of the Services will not violate any applicable law or regulation.'),
        const SizedBox(height: 20),
        _buildSectionTitle('4. PROHIBITED ACTIVITIES'),
        const SizedBox(height: 15),
        _buildParagraph(
          'You may not access or use the Services for any purpose other than that for which we make the Services available. As a user of the Services, you agree not to:',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('Systematically retrieve data or other content from the Services without written permission from us.'),
        _buildBulletPoint('Trick, defraud, or mislead us and other users.'),
        _buildBulletPoint('Circumvent, disable, or otherwise interfere with security-related features of the Services.'),
        _buildBulletPoint('Disparage, tarnish, or otherwise harm us and/or the Services.'),
        _buildBulletPoint('Use any information obtained from the Services to harass, abuse, or harm another person.'),
        _buildBulletPoint('Make improper use of our support services or submit false reports of abuse or misconduct.'),
        const SizedBox(height: 20),
        _buildSectionTitle('5. USER GENERATED CONTRIBUTIONS'),
        const SizedBox(height: 15),
        _buildParagraph(
          'The Services may invite you to chat, contribute to, or participate in blogs, message boards, online forums, and other functionality. Any Contributions you transmit may be treated as non-confidential and non-proprietary.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('6. TERM AND TERMINATION'),
        const SizedBox(height: 15),
        _buildParagraph(
          'These Legal Terms shall remain in full force and effect while you use the Services. We reserve the right to deny access to and use of the Services to any person for any reason or for no reason.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('7. GOVERNING LAW'),
        const SizedBox(height: 15),
        _buildParagraph(
          'These Legal Terms shall be governed by and defined following the laws of Peru. ThinkUp and yourself irrevocably consent that the courts of Peru shall have exclusive jurisdiction to resolve any dispute which may arise in connection with these Legal Terms.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('8. DISCLAIMER'),
        const SizedBox(height: 15),
        _buildParagraph(
          'THE SERVICES ARE PROVIDED ON AN AS-IS AND AS-AVAILABLE BASIS. YOU AGREE THAT YOUR USE OF THE SERVICES WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('9. LIMITATIONS OF LIABILITY'),
        const SizedBox(height: 15),
        _buildParagraph(
          'IN NO EVENT WILL WE OR OUR DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('10. CONTACT US'),
        const SizedBox(height: 15),
        _buildParagraph('In order to resolve a complaint regarding the Services or to receive further information regarding use of the Services, please contact us at:'),
        const SizedBox(height: 15),
        _buildParagraph('ThinkUp'),
        _buildParagraph('Magdalena, Lima, Lima, Peru'),
        _buildParagraph('Phone: 978777386'),
        _buildParagraph('Email: skillshare@thinkup.com'),
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