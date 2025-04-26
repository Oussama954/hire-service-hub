import 'package:e_commerce/common/buttons/custom_gradient_button.dart';
import 'package:e_commerce/common/snakbar/custom_snakbar.dart';
import 'package:e_commerce/models/service/create_service_model.dart';
import 'package:e_commerce/models/service/fetch_signle_service_model.dart';
import 'package:e_commerce/providers/category/category_provider.dart';
import 'package:e_commerce/providers/city/city_provider.dart';
import 'package:e_commerce/providers/service/service_provider.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateServiceScreen extends StatefulWidget {
  final FetchSingleService serviceDetail;

  const UpdateServiceScreen({super.key, required this.serviceDetail});

  @override
  State<UpdateServiceScreen> createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  bool _isLoading = false;
  File? _newCoverPhoto;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Load categories and cities simultaneously
        await Future.wait([
          Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
          Provider.of<CityProvider>(context, listen: false).fetchCities(),
        ]);
        
        // Get the service details
        if (widget.serviceDetail.data?.specificService != null) {
          final service = widget.serviceDetail.data!.specificService!;
          final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
          final cityProvider = Provider.of<CityProvider>(context, listen: false);
          
          // Initialize form values
          serviceProvider.resetCreateServiceValues();
          
          // Set service name with null check
          if (service.serviceName != null) {
            serviceProvider.nameController.text = service.serviceName ?? '';
          }

          // Set description with null check
          if (service.description != null) {
            serviceProvider.descriptionController.text = service.description ?? '';
          }
          
          // Set price with null check
          if (service.price != null) {
            serviceProvider.priceController.text = service.price.toString();
          }
          
          // Set category with null check
          if (service.category != null && service.category?.title != null) {
            serviceProvider.setCategory(service.category!.title.toString());
          }

          // Set city if available
          if (service.city != null) {
            serviceProvider.setCity(service.city.toString());
          } else if (cityProvider.cities.isNotEmpty) {
            // Default to first city if service city is not set
            final cityName = cityProvider.cities[0].name;
            if (cityName != null) {
              serviceProvider.setCity(cityName);
            }
          }
          
          // Set time values with null checks
          if (service.startTime != null) {
            setState(() {
              _startTime = service.startTime!;
            });
            serviceProvider.startTimeController.text = DateFormat('h:mm a').format(service.startTime!);
          } else {
            serviceProvider.startTimeController.text = DateFormat('h:mm a').format(_startTime);
          }
          
          if (service.endTime != null) {
            setState(() {
              _endTime = service.endTime!;
            });
            serviceProvider.endTimeController.text = DateFormat('h:mm a').format(service.endTime!);
          } else {
            serviceProvider.endTimeController.text = DateFormat('h:mm a').format(_endTime);
          }
          
          // Set availability with null check
          serviceProvider.toggleAvailability(service.isAvailable ?? true);
        }
      } catch (e) {
        // Handle any errors that might occur during initialization
        if (mounted) {
          showCustomSnackBar(context, "Error loading service data: ${e.toString()}", Colors.red);
        }
      }
    });
  }
  
  Future<void> _selectTime(BuildContext context, {
      required TextEditingController controller,
      required Function(DateTime) onTimeSelected}) async {
    // Extract the current time from the controller if it has a value
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      try {
        // Try to parse the existing time in the controller
        final parsedTime = DateFormat('h:mm a').parse(controller.text);
        initialTime = TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
      } catch (e) {
        // Fallback to current time if parsing fails
        initialTime = TimeOfDay.now();
      }
    }
    
    // Show time picker with the appropriate initial time
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.black : Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black54 : Colors.grey.shade200,
              dayPeriodTextColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : Colors.black87,
              hourMinuteColor: AppTheme.primaryColor.withOpacity(0.15),
              hourMinuteTextColor: AppTheme.primaryColor,
              dialHandColor: AppTheme.primaryColor,
              dialBackgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade900 : Colors.grey.shade100,
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppTheme.primaryColor,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
          now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

      // Format the selected time to 12-hour format with AM/PM
      controller.text = DateFormat('h:mm a').format(dateTime);

      // Notify the parent to update the internal DateTime
      onTimeSelected(dateTime);
    }
  }

  Future<void> _selectImage() async {
    // Show a bottom sheet with camera and gallery options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        "Select Photo Source",
        [
          _buildBottomSheetOption(
            IconlyLight.camera,
            "Take Photo",
            () async {
              Navigator.pop(context);
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                setState(() {
                  _newCoverPhoto = File(pickedFile.path);
                });
              }
            },
          ),
          _buildBottomSheetOption(
            IconlyLight.image,
            "Choose from Gallery",
            () async {
              Navigator.pop(context);
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _newCoverPhoto = File(pickedFile.path);
                });
              }
            },
          ),
        ],
      ),
    );
  }
  
  // Helper to build bottom sheet options
  Widget _buildBottomSheetOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: GoogleFonts.inter()),
      onTap: onTap,
    );
  }
  
  // Helper to build the bottom sheet
  Widget _buildBottomSheet(String title, List<Widget> options) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
          const Divider(),
          ...options,
        ],
      ),
    );
  }
  
  // Method to open filter bottom sheet for category and city selection
  Future<void> _openFilterBottomSheet({
    required String title,
    required BuildContext context,
    required List<String> options,
    required Function(String?) onSelect,
    required VoidCallback onReset,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            const Divider(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      options[index],
                      style: GoogleFonts.inter(),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(options[index]);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onReset();
                  },
                  child: Text('Reset', style: GoogleFonts.inter()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Validation Method
  bool _validateInputs(ServiceProvider serviceProvider) {
    return serviceProvider.nameController.text.trim().isNotEmpty &&
        serviceProvider.descriptionController.text.trim().isNotEmpty &&
        serviceProvider.priceController.text.trim().isNotEmpty &&
        serviceProvider.startTimeController.text.trim().isNotEmpty &&
        serviceProvider.endTimeController.text.trim().isNotEmpty &&
        serviceProvider.selectedCategory.isNotEmpty;
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final cityProvider = Provider.of<CityProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Update Service',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white70 : AppTheme.darkGrey.withOpacity(0.7),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service cover photo
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: size.width * 0.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1,
                    ),
                    image: _newCoverPhoto != null
                        ? DecorationImage(
                            image: FileImage(_newCoverPhoto!),
                            fit: BoxFit.cover,
                          )
                        : widget.serviceDetail.data?.specificService?.coverPhoto != null
                            ? DecorationImage(
                                image: NetworkImage(
                                  widget.serviceDetail.data!.specificService!.coverPhoto!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: (_newCoverPhoto == null && 
                         (widget.serviceDetail.data?.specificService?.coverPhoto == null || 
                          widget.serviceDetail.data!.specificService!.coverPhoto!.isEmpty))
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                IconlyLight.camera,
                                size: 48,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Cover Photo',
                                style: GoogleFonts.inter(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(IconlyLight.edit, color: Colors.white, size: 20),
                                onPressed: _selectImage,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Service name field
              Text(
                'Service Name',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: serviceProvider.nameController,
                style: GoogleFonts.inter(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter service name',
                  hintStyle: GoogleFonts.inter(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description field
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: serviceProvider.descriptionController,
                style: GoogleFonts.inter(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter service description',
                  hintStyle: GoogleFonts.inter(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Price field
              Text(
                'Price',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: serviceProvider.priceController,
                style: GoogleFonts.inter(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  hintStyle: GoogleFonts.inter(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    IconlyLight.wallet,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category selection
              Text(
                'Category',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (categoryProvider.categories.isNotEmpty) {
                    final categoryNames = categoryProvider.categories
                        .map((cat) => cat.title ?? 'Unknown Category')
                        .where((name) => name != 'Unknown Category')
                        .toList();
                    
                    _openFilterBottomSheet(
                      title: 'Select Category',
                      context: context,
                      options: categoryNames,
                      onSelect: (category) {
                        if (category != null) {
                          serviceProvider.setCategory(category);
                        }
                      },
                      onReset: () {
                        serviceProvider.setCategory('');
                      },
                    );
                  } else {
                    showCustomSnackBar(
                      context, 
                      "Categories are not loaded yet", 
                      Colors.red,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconlyLight.category,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          serviceProvider.selectedCategory.isNotEmpty
                              ? serviceProvider.selectedCategory
                              : 'Select a category',
                          style: GoogleFonts.inter(
                            color: serviceProvider.selectedCategory.isNotEmpty
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // City selection
              Text(
                'City',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (cityProvider.cities.isNotEmpty) {
                    final cityNames = cityProvider.cities
                        .map((city) => city.name ?? 'Unknown City')
                        .where((name) => name != 'Unknown City')
                        .toList();
                    
                    _openFilterBottomSheet(
                      title: 'Select City',
                      context: context,
                      options: cityNames,
                      onSelect: (city) {
                        if (city != null) {
                          serviceProvider.setCity(city);
                        }
                      },
                      onReset: () {
                        serviceProvider.setCity('');
                      },
                    );
                  } else {
                    showCustomSnackBar(
                      context, 
                      "Cities are not loaded yet", 
                      Colors.red,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconlyLight.location,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          serviceProvider.selectedCity.isNotEmpty
                              ? serviceProvider.selectedCity
                              : 'Select a city',
                          style: GoogleFonts.inter(
                            color: serviceProvider.selectedCity.isNotEmpty
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Time selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _selectTime(
                              context,
                              controller: serviceProvider.startTimeController,
                              onTimeSelected: (time) {
                                setState(() {
                                  _startTime = time;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[900] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  IconlyLight.time_circle,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    serviceProvider.startTimeController.text,
                                    style: GoogleFonts.inter(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _selectTime(
                              context,
                              controller: serviceProvider.endTimeController,
                              onTimeSelected: (time) {
                                setState(() {
                                  _endTime = time;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[900] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  IconlyLight.time_circle,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    serviceProvider.endTimeController.text,
                                    style: GoogleFonts.inter(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Availability toggle
              SwitchListTile(
                title: Text(
                  'Available',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                  ),
                ),
                subtitle: Text(
                  'Toggle service availability',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                value: serviceProvider.isAvailable,
                onChanged: (value) {
                  serviceProvider.toggleAvailability(value);
                },
                activeColor: AppTheme.primaryColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              
              const SizedBox(height: 32),
              
              // Update button
              CustomGradientButton(
                onPressed: _isLoading ? null : () async {
                  if (_validateInputs(serviceProvider)) {
                    setState(() {
                      _isLoading = true;
                    });
                    
                    try {
                      // Debug logging for form values
                      debugPrint('🔄 UPDATE SERVICE FORM VALUES:');
                      debugPrint('🔹 Service Name: ${serviceProvider.nameController.text.trim()}');
                      debugPrint('🔹 Description: ${serviceProvider.descriptionController.text.trim()}');
                      debugPrint('🔹 Price: ${serviceProvider.priceController.text.trim()}');
                      debugPrint('🔹 Category: ${serviceProvider.selectedCategory}');
                      debugPrint('🔹 Category ID: ${categoryProvider.getCategoryIdByName(serviceProvider.selectedCategory)}');
                      debugPrint('🔹 City: ${serviceProvider.selectedCity}');
                      debugPrint('🔹 City ID: ${cityProvider.getCityIdByName(serviceProvider.selectedCity)}');
                      debugPrint('🔹 Start Time: ${_startTime.toString()}');
                      debugPrint('🔹 End Time: ${_endTime.toString()}');
                      debugPrint('🔹 Available: ${serviceProvider.isAvailable}');
                      
                      // 1. First update the service details
                      final cityId = cityProvider.getCityIdByName(serviceProvider.selectedCity);
                      final categoryId = categoryProvider.getCategoryIdByName(serviceProvider.selectedCategory);
                      
                      if (cityId == null || cityId.isEmpty) {
                        throw Exception("Invalid city selected. Please select a valid city.");
                      }
                      
                      if (categoryId == null || categoryId.isEmpty) {
                        throw Exception("Invalid category selected. Please select a valid category.");
                      }
                      
                      final serviceData = CreateService(
                        serviceName: serviceProvider.nameController.text.trim(),
                        description: serviceProvider.descriptionController.text.trim(),
                        price: int.parse(serviceProvider.priceController.text.trim()),
                        startTime: _startTime.toString(),
                        endTime: _endTime.toString(),
                        categoryId: categoryId,
                        cityId: cityId,
                        city: serviceProvider.selectedCity,
                        isAvailable: serviceProvider.isAvailable,
                        coverPhoto: widget.serviceDetail.data?.specificService?.coverPhoto ?? '',
                      );
                      
                      debugPrint('🔹 Service Data Object: $serviceData');
                      String serviceId = widget.serviceDetail.data!.specificService!.id!;
                      debugPrint('🔹 Service ID: $serviceId');
                      
                      // Call update service method
                      final success = await serviceProvider.updateService(serviceId, serviceData);
                      
                      if (!success) {
                        throw Exception(serviceProvider.errorMessage ?? "Failed to update service.");
                      }
                      
                      // 2. If a new cover photo was selected, upload it
                      if (_newCoverPhoto != null) {
                        debugPrint('🔹 Uploading new cover photo from: ${_newCoverPhoto!.path}');
                        await serviceProvider.uploadServiceCoverPhoto(
                          _newCoverPhoto!.path,
                          serviceId,
                        );
                      }
                      
                      showCustomSnackBar(context, "Service updated successfully!", Colors.green);
                      Navigator.pop(context);
                    } catch (e) {
                      showCustomSnackBar(context, "Error updating service: ${e.toString()}", Colors.red);
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  } else {
                    showCustomSnackBar(context, "Please fill in all required fields", Colors.red);
                  }
                },
                text: "Update Service",
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
