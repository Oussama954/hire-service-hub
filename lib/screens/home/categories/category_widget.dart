import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/models/category/category.dart';
import 'package:e_commerce/screens/service/service_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final double? width;
  final double? rightPadding;

  const CategoryItem({
    super.key,
    required this.category,
    this.width,
    this.rightPadding,
  });

  // Helper method to get appropriate icon based on category type
  IconData _getCategoryIcon(String categoryTitle) {
    // Match category names to appropriate icons
    if (categoryTitle.contains('home')) {
      return Icons.home_repair_service_outlined;
    } else if (categoryTitle.contains('cleaning') || categoryTitle.contains('house')) {
      return Icons.cleaning_services_outlined;
    } else if (categoryTitle.contains('electrical') || categoryTitle.contains('electric')) {
      return Icons.electrical_services_outlined;
    } else if (categoryTitle.contains('plumbing') || categoryTitle.contains('water')) {
      return Icons.plumbing_outlined;
    } else if (categoryTitle.contains('beauty') || categoryTitle.contains('salon')) {
      return Icons.spa_outlined;
    } else if (categoryTitle.contains('car') || categoryTitle.contains('auto')) {
      return Icons.car_repair_outlined;
    } else if (categoryTitle.contains('health') || categoryTitle.contains('medical')) {
      return Icons.medical_services_outlined;
    } else if (categoryTitle.contains('education') || categoryTitle.contains('tutor')) {
      return Icons.school_outlined;
    } else if (categoryTitle.contains('food') || categoryTitle.contains('catering')) {
      return Icons.restaurant_outlined;
    } else if (categoryTitle.contains('moving') || categoryTitle.contains('transport')) {
      return Icons.local_shipping_outlined;
    } else if (categoryTitle.contains('tech') || categoryTitle.contains('computer')) {
      return Icons.computer_outlined;
    } else if (categoryTitle.contains('design') || categoryTitle.contains('art')) {
      return Icons.design_services_outlined;
    } else if (categoryTitle.contains('garden') || categoryTitle.contains('lawn')) {
      return Icons.yard_outlined;
    } else if (categoryTitle.contains('pet') || categoryTitle.contains('animal')) {
      return Icons.pets_outlined;
    }
    
    // Default icon for other categories
    return Icons.miscellaneous_services_outlined;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Default to a slightly wider width for a better visual
    final itemWidth = width ?? 90.0;
    final rightPaddingValue = rightPadding ?? 12;

    return Container(
      width: itemWidth,
      height: 100, // Slightly taller for better spacing
      margin: EdgeInsets.only(right: rightPaddingValue),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
        boxShadow: isDarkMode ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              SlidePageRoute(
                page: ServiceScreen(categoryModel: category),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category icon with modern styling based on category type
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(category.title?.toLowerCase() ?? ''),
                  color: isDarkMode ? AppTheme.primaryColor.withOpacity(0.9) : AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              
              // Category title with improved typography and aggressive truncation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: itemWidth - 8, // Constrain width for consistent truncation
                  child: Text(
                    category.title ?? 'Category',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1, // More aggressive truncation
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
