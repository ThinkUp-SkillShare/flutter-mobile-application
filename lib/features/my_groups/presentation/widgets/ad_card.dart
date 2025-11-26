import 'package:flutter/material.dart';

/// Simple UI component used to display a sponsored advertisement block.
/// Inserted between group items to mimic a native ad placement.
class AdCard extends StatelessWidget {
  const AdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      /// Fixed height to keep all ad blocks visually consistent.
      height: 80,
      decoration: BoxDecoration(
        /// White background for a clean and neutral appearance.
        color: Colors.white,

        /// Rounded corners to match the app's design language.
        borderRadius: BorderRadius.circular(12),

        /// Subtle border to differentiate the ad from surrounding items.
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// Leading icon to indicate promotional or sponsored content.
            Icon(Icons.campaign_outlined, color: Colors.amber[700], size: 28),

            const SizedBox(width: 12),

            /// Main label describing the sponsored block.
            const Expanded(
              child: Text(
                'Sponsored Content',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ),

            /// Trailing arrow suggesting the card is tappable,
            /// even though no action is currently attached.
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
