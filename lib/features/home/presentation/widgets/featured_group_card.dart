import 'package:flutter/material.dart';

/// Card widget used to display a featured group within a horizontal list.
/// It includes a cover image, subject tag, title, description, and member count.
/// The entire card is tappable through the provided `onTap` callback.
class FeaturedGroupCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const FeaturedGroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// The whole card acts as a button and triggers `onTap`.
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          /// Soft shadow for a card-like elevation feel.
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),   // Header with cover image + gradient + subject label
            _buildContent(),  // Card content: title, description, member count
          ],
        ),
      ),
    );
  }

  /// Builds the top section of the card, showing the cover image and subject label.
  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),

        /// Fallback image ensures UI stability if backend sends null.
        image: DecorationImage(
          image: NetworkImage(
            group['coverImage'] ?? 'https://i.pinimg.com/originals/79/28/79/7928798bbdeda1d1cb82adb1f14e99cf.gif',
          ),
          fit: BoxFit.cover,
        ),
      ),

      /// Gradient overlay improves text readability on light backgrounds.
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),

        /// Subject label positioned at the top-left corner.
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group['subjectName'] ?? 'General',
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the lower section of the card: group name, description, and member count.
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Group title with ellipsis to avoid overflow.
          Text(
            group['name'] ?? 'No name',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          /// Short group description, limited to two lines.
          Text(
            group['description'] ?? 'No description',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          /// Member count indicator with small icon.
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${group['memberCount'] ?? 0} members',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
