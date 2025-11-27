import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        bool isSelected = selectedCategory == cat['name'];

        return GestureDetector(
          onTap: () => onCategorySelected(cat['name']),
          child: Column(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                ),
                child: Icon(cat['icon'], color: Colors.black87, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                cat['name'],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      },
    );
  }
}