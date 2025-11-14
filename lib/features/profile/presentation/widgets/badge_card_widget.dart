import 'package:flutter/material.dart';

class BadgeCardWidget extends StatelessWidget {
  final Map<String, dynamic> badge;

  const BadgeCardWidget({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badge['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge['icon'],
              color: badge['color'],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge['name'],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}