import 'package:flutter/material.dart';

/// Widget to display the app logo on the login screen
class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/logo/SkillShare_logo.png",
        height: 120,
        width: 120,
        fit: BoxFit.contain,
      ),
    );
  }
}
