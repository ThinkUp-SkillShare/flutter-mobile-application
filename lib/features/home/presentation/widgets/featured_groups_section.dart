import 'package:flutter/material.dart';
import '../../../groups/presentation/views/group_detail_screen.dart';
import 'featured_group_card.dart';

/// Section displayed on the home screen showing a horizontal list
/// of featured groups, including a title and a scrollable card list.
/// Each card navigates to the group detail page when tapped.
class FeaturedGroupsSection extends StatelessWidget {
  final List<Map<String, dynamic>> featuredGroups;
  final String title;

  const FeaturedGroupsSection({
    super.key,
    required this.featuredGroups,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    /// If no featured groups are available, skip rendering this section.
    return featuredGroups.isEmpty
        ? const SizedBox.shrink()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section title (e.g., "Featured Groups")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /// Horizontal scrollable list of group cards.
        /// Card height is fixed to ensure consistent layout.
        SizedBox(
          height: 235,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: featuredGroups.length,
            itemBuilder: (context, index) {
              final group = featuredGroups[index];

              return FeaturedGroupCard(
                group: group,

                /// Navigates to the group detail screen using the group's ID.
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailScreen(
                        groupId: group['id'] ?? 0, // Fallback prevents crashes
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
