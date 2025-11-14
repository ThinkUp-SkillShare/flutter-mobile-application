import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function() onClearSearch;

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search groups, subjects, topics...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF0F4C75),
            size: 22,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            onPressed: onClearSearch,
            icon: const Icon(
              Icons.clear,
              color: Color(0xFF0F4C75),
              size: 20,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
