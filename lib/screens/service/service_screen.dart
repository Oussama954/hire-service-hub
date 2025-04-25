// ignore_for_file: use_build_context_synchronously

import 'package:e_commerce/models/category/category.dart';
import 'package:e_commerce/models/service/service_model.dart';
import 'package:e_commerce/providers/category/category_provider.dart';
import 'package:e_commerce/providers/city/city_provider.dart';
import 'package:e_commerce/providers/service/service_filter_provider.dart';
import 'package:e_commerce/providers/service/service_provider.dart';
import 'package:e_commerce/screens/service/widgets/service_card_widget.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/info_helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ServiceScreen extends StatefulWidget {
  final Category? categoryModel;
  const ServiceScreen({super.key, this.categoryModel});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> with SingleTickerProviderStateMixin {
  final List<String> priceFilters = ["All", "Low to High", "High to Low"];
  final List<String> ratingFilters = ["All", "5 Star", "4+ Star", "3+ Star"];
  String selectedPriceFilter = "All";
  String selectedRatingFilter = "All";
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load categories and cities from server immediately and await completion
      await Future.wait([
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
        Provider.of<CityProvider>(context, listen: false).fetchCities(),
      ]);
      
      final filterProvider =
          Provider.of<FilterProvider>(context, listen: false);

      if (widget.categoryModel != null && widget.categoryModel!.id != null) {
        // Set the category ID filter on initialization
        filterProvider.setCategory(
          widget.categoryModel!.title!,
          widget.categoryModel!.id!,
        );

        filterProvider.setFilter("Category", widget.categoryModel!.title);

        // Fetch services with applied filters
        Provider.of<ServiceProvider>(context, listen: false)
            .fetchFilterServices(
          categoryId: filterProvider.selectedFilters['CategoryID'],
        );
      } else {
        // Fetch all services if no category is specified
        Provider.of<ServiceProvider>(context, listen: false).fetchFilterServices();
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }
  
  // Helper method to return info message for the user
  String _getHelperMessage() {
    return "Browse services based on categories, location, price, and ratings. Filter to find exactly what you need.";
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final cityProvider = Provider.of<CityProvider>(context);
    final filterProvider = Provider.of<FilterProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isSearching ? "Search Services" : "Services",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : AppTheme.accentText),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          // Search icon
          IconButton(
            icon: Icon(isSearching ? IconlyLight.close_square : IconlyLight.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  // Reset search filter
                  serviceProvider.searchServices("");
                }
              });
            },
          ),
          // Info button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(IconlyLight.info_circle),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Information',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppTheme.accentText,
                          fontSize: 18,
                        ),
                      ),
                      content: Text(
                        _getHelperMessage(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.secondaryColor, 
                          ),
                          child: Text(
                            'Got it',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.secondaryColor,
            indicatorWeight: 3,
            labelColor: isDarkMode ? Colors.white : AppTheme.primaryColor,
            unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.grey.shade600,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: "All Services"),
              Tab(text: "Popular"),
              Tab(text: "Newest"),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar - Shown only when searching
          if (isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search services...",
                  prefixIcon: Icon(IconlyLight.search, color: isDarkMode ? Colors.white60 : Colors.grey),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.darkSurface : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radius_md),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  serviceProvider.searchServices(value);
                },
              ),
            ),
          
          // Filter section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and City Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Price filter
                      Row(
                        children: priceFilters.map((filter) => buildFilterChip(
                          filter,
                          selectedPriceFilter == filter,
                          (selected) {
                            if (selected) {
                              setState(() {
                                selectedPriceFilter = filter;
                              });
                              
                              // Apply filter
                              if (filter == "Low to High") {
                                filterProvider.setFilter("Price", "Low To High");
                              } else if (filter == "High to Low") {
                                filterProvider.setFilter("Price", "High To Low");
                              } else {
                                filterProvider.resetFilter("Price");
                              }
                              
                              // Fetch filtered services
                              serviceProvider.fetchFilterServices(
                                categoryId: filterProvider.selectedFilters['CategoryID'],
                                cityId: filterProvider.selectedFilters['CityID'],
                                priceRangetype: filterProvider.selectedFilters['Price'],
                              );
                            }
                          },
                        )).toList(),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Rating filter
                      Row(
                        children: ratingFilters.map((filter) => buildFilterChip(
                          filter,
                          selectedRatingFilter == filter,
                          (selected) {
                            if (selected) {
                              setState(() {
                                selectedRatingFilter = filter;
                              });
                              
                              // Here you would apply rating filter logic
                              // For now just updating UI state
                            }
                          },
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Category and City filter tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Category filter
                      if (categoryProvider.categories.isNotEmpty)
                        buildDropdownFilter(
                          "Category",
                          categoryProvider.categories.map((c) => c.title ?? "").toList(),
                          filterProvider.selectedFilters["Category"],
                          (value) {
                            if (value != null) {
                              final category = categoryProvider.categories.firstWhere(
                                (c) => c.title == value,
                                orElse: () => categoryProvider.categories.first,
                              );
                              filterProvider.setCategory(value, category.id ?? "");
                              
                              // Fetch with updated filter
                              serviceProvider.fetchFilterServices(
                                categoryId: filterProvider.selectedFilters['CategoryID'],
                                cityId: filterProvider.selectedFilters['CityID'],
                                priceRangetype: filterProvider.selectedFilters['Price'],
                              );
                            }
                          },
                        ),
                      
                      const SizedBox(width: 12),
                      
                      // City filter
                      if (cityProvider.cities.isNotEmpty)
                        buildDropdownFilter(
                          "Location",
                          cityProvider.cities.map((c) => c.name ?? "").toList(),
                          filterProvider.selectedFilters["City"],
                          (value) {
                            if (value != null) {
                              final city = cityProvider.cities.firstWhere(
                                (c) => c.name == value,
                                orElse: () => cityProvider.cities.first,
                              );
                              // Use setFilter to set both City and CityID
                              filterProvider.setFilter("City", value);
                              filterProvider.setFilter("CityID", city.id ?? "");
                              
                              // Fetch with updated filter
                              serviceProvider.fetchFilterServices(
                                categoryId: filterProvider.selectedFilters['CategoryID'],
                                cityId: filterProvider.selectedFilters['CityID'],
                                priceRangetype: filterProvider.selectedFilters['Price'],
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(height: 1, thickness: 1, color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
          
          // Service list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Services Tab
                buildServicesTab(serviceProvider, isDarkMode),
                // Popular Tab
                buildServicesTab(serviceProvider, isDarkMode, sortType: "popular"),
                // New Tab
                buildServicesTab(serviceProvider, isDarkMode, sortType: "newest"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build service tab content
  Widget buildServicesTab(ServiceProvider provider, bool isDarkMode, {String? sortType}) {
    if (provider.isLoading) {
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: isDarkMode ? Colors.white : AppTheme.primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    } else if ((provider.errorMessage ?? "").isNotEmpty) {
      return Center(child: Text('Error: ${provider.errorMessage}'));
    }
    
    // Determine which service list to show
    List<ServiceModel> servicesToShow;
    
    if (isSearching && provider.isSearching) {
      // Show search results if searching
      servicesToShow = provider.searchResults;
      
      if (servicesToShow.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconlyLight.search,
                size: 64,
                color: isDarkMode ? Colors.white60 : AppTheme.mediumGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'No matching services found',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      // Show filtered services
      servicesToShow = provider.filteredServices;
      
      if (servicesToShow.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconlyLight.document,
                size: 64,
                color: isDarkMode ? Colors.white60 : AppTheme.mediumGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'No services available',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        );
      }
    }
    
    // Apply additional sorting if needed based on tab
    if (sortType == "popular") {
      // Sort by rating (would need rating field in your service model)
      // This is a placeholder; adjust according to your actual data model
      servicesToShow = List.from(servicesToShow);
    } else if (sortType == "newest") {
      // Sort by creation date (would need date field in your service model)
      // This is a placeholder; adjust according to your actual data model
      servicesToShow = List.from(servicesToShow);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: servicesToShow.length,
      itemBuilder: (context, index) {
        final service = servicesToShow[index];
        return ServiceCard(service: service);
      },
    );
  }
  
  // Helper method to build filter chips
  Widget buildFilterChip(String label, bool isSelected, Function(bool) onSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected 
                ? Colors.white 
                : isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        selected: isSelected,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        selectedColor: AppTheme.secondaryColor,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius_circle),
        ),
        onSelected: onSelected,
      ),
    );
  }
  
  // Helper method to build dropdown filters
  Widget buildDropdownFilter(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.radius_md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
            ),
          ),
          DropdownButton<String>(
            value: selectedValue,
            icon: Icon(IconlyLight.arrow_down_2, size: 16, color: isDarkMode ? Colors.white60 : Colors.grey.shade700),
            elevation: 8,
            underline: const SizedBox(), // Remove underline
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            dropdownColor: isDarkMode ? Colors.black : Colors.white,
            hint: Text("Select", style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey)),
            items: ["All", ...options].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value == "All" ? null : value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
