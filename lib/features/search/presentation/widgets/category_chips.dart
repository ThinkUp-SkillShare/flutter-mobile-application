import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryChip(category);
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) => onCategorySelected(category),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF0F4C75),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF2C3E50),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0F4C75) : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}