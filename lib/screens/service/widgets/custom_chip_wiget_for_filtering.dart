import 'package:e_commerce/models/category/category.dart';
import 'package:e_commerce/models/city/city_model.dart';
import 'package:e_commerce/providers/category/category_provider.dart';
import 'package:e_commerce/providers/city/city_provider.dart';
import 'package:e_commerce/providers/service/service_filter_provider.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/bottom_sheet_helpers.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

GestureDetector customChipWidget(
  BuildContext context,
  FilterProvider filterProvider,
  bool isDarkMode,
  String title,
  List<String> options,
) {
  return GestureDetector(
    onTap: () async {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loading ${title.toLowerCase()}s...'), 
          duration: Duration(milliseconds: 500),
        )
      );
      
      // Always reload data to ensure it's fresh
      if (title == "City") {
        await Provider.of<CityProvider>(context, listen: false).fetchCities();
      } else if (title == "Category") {
        await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      }
      
      // Get the current options directly from the appropriate provider
      List<String> currentOptions = [];
      if (title == "City") {
        currentOptions = Provider.of<CityProvider>(context, listen: false).cityNames;
      } else if (title == "Category") {
        currentOptions = Provider.of<CategoryProvider>(context, listen: false).categoryNames;
      } else {
        // Use the options passed for other filter types
        currentOptions = options;
      }
      
      // Only open bottom sheet if we have options to show
      if (currentOptions.isNotEmpty) {
        openFilterBottomSheet(
          context: context,
          title: title,
          options: currentOptions,
        onSelect: (String? value) async {
          if (title == "Category") {
            // Get the selected category object from the CategoryProvider based on the category title
            try {
              Category selectedCategory =
                  Provider.of<CategoryProvider>(context, listen: false)
                      .categories
                      .firstWhere((category) => category.title == value);

              // Set both the name and ID in the filter provider
              await filterProvider.setCategory(selectedCategory.title!,
                  selectedCategory.id!); // Pass the ID (UUID)
            } catch (e) {
              print('Category not found: $value');
              return; // Exit the function if category is not found
            }
          } else if (title == "City") {
            // Get the selected city object from the CityProvider based on the city name
            try {
              String? cityId = Provider.of<CityProvider>(context, listen: false)
                  .getCityIdByName(value!);
              
              if (cityId != null && cityId.isNotEmpty) {
                // Store the city ID in the filter provider
                filterProvider.setFilter('CityID', cityId);
              }
            } catch (e) {
              print('City not found: $value');
              return; // Exit the function if city is not found
            }
          }
          filterProvider.setFilter(
              title, value); // Set the selected filter for this type

          Navigator.pop(context);
        },
        onReset: () {
          filterProvider
              .resetFilter(title); // Reset the selected filter for this type
          Navigator.pop(context);
        },
        );
      } else {
        // Show message if no options available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No ${title.toLowerCase()} options available'))
        );
      }
    },
    child: Chip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      side: BorderSide(
        color: isDarkMode ? AppTheme.fdarkBlue : Colors.grey,
       
      ),
      label: Text(
        filterProvider.getFilter(title) ?? title,
        style: TextStyle(
          color: filterProvider.isFilterApplied(title)
              ? isDarkMode
                  ? Colors.white
                  : Colors.white
              : isDarkMode
                  ? Colors.white
                  : Colors.black,
        ),
      ),
      backgroundColor: filterProvider.isFilterApplied(title)
          ? isDarkMode
              ? AppTheme.fdarkBlue
              : AppTheme.fMainColor
          : isDarkMode
              ? AppTheme.fdarkBlue
              : Colors.white,
    
      labelStyle: TextStyle(
        color: filterProvider.isFilterApplied(title)
            ? isDarkMode
                ? Colors.white
                : Colors.white
            : isDarkMode
                ? Colors.white
                : Colors.black,
      ),
      onDeleted: filterProvider.isFilterApplied(title)
          ? () {
              if (title == "Category") {
                filterProvider.resetCategoryID();
              } else if (title == "City") {
                filterProvider.resetFilter('CityID');
              }
              filterProvider.resetFilter(title);
            }
          : () {
              // Get the current options directly from the appropriate provider
              List<String> currentOptions = [];
              if (title == "City") {
                currentOptions = Provider.of<CityProvider>(context, listen: false).cityNames;
              } else if (title == "Category") {
                currentOptions = Provider.of<CategoryProvider>(context, listen: false).categoryNames;
              } else {
                // Use the options passed for other filter types
                currentOptions = options;
              }
              
              openFilterBottomSheet(
                context: context,
                title: title,
                options: currentOptions,
                onSelect: (String? value) async {
                  if (title == "Category") {
                    // Get the selected category object from the CategoryProvider based on the category title
                    try {
                      Category selectedCategory =
                          Provider.of<CategoryProvider>(context, listen: false)
                              .categories
                              .firstWhere((category) => category.title == value);

                      // Set both the name and ID in the filter provider
                      await filterProvider.setCategory(selectedCategory.title!,
                          selectedCategory.id!); // Pass the ID (UUID)
                    } catch (e) {
                      print('Category not found: $value');
                      return; // Exit the function if category is not found
                    }
                  } else if (title == "City") {
                    // Get the selected city object from the CityProvider based on the city name
                    try {
                      String? cityId = Provider.of<CityProvider>(context, listen: false)
                          .getCityIdByName(value!);
                      
                      if (cityId != null && cityId.isNotEmpty) {
                        // Store the city ID in the filter provider
                        filterProvider.setFilter('CityID', cityId);
                      }
                    } catch (e) {
                      print('City not found: $value');
                      return; // Exit the function if city is not found
                    }
                  }
                  filterProvider.setFilter(
                      title, value); // Set the selected filter for this type

                  Navigator.pop(context);
                },
                onReset: () {
                  if (title == "Category") {
                    filterProvider.resetCategoryID();
                  } else if (title == "City") {
                    filterProvider.resetFilter('CityID');
                  }
                  filterProvider.resetFilter(title);

                  Navigator.pop(context);
                },
              );
            },
      deleteIcon: Icon(
        filterProvider.isFilterApplied(title)
            ? Icons.cancel
            : IconlyLight.arrow_down_2,
        color: filterProvider.isFilterApplied(title)
            ? isDarkMode
                ? Colors.white
                : Colors.white
            : isDarkMode
                ? Colors.white
                : Colors.black,
      ),
    ),
  );
}
