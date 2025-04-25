import 'package:e_commerce/common/buttons/custom_gradient_button.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/common/snakbar/custom_snakbar.dart';
import 'package:e_commerce/common/text_form_fields/custom_text_form_field.dart';
import 'package:e_commerce/models/service/create_service_model.dart';
import 'package:e_commerce/providers/category/category_provider.dart';
import 'package:e_commerce/providers/city/city_provider.dart';
import 'package:e_commerce/providers/service/service_provider.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/bottom_sheet_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load both categories and cities simultaneously
      await Future.wait([
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
        Provider.of<CityProvider>(context, listen: false).fetchCities(),
      ]);

      Provider.of<ServiceProvider>(context, listen: false)
          .resetCreateServiceValues();
    });
  }

  Future<void> _selectTime(BuildContext context,
      {required TextEditingController controller,
        required ValueChanged<DateTime> onTimeSelected}) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ImagePicker picker = ImagePicker();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create New Service',
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
    body: SingleChildScrollView(
      child: Consumer3<ServiceProvider, CategoryProvider, CityProvider>(
        builder: (context, serviceProvider, categoryProvider, cityProvider, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Text(
                  "Service Information",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                  ),
                ),
                Text(
                  "Fill in the details below to create your service listing",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Cover Photo Section
                Text(
                  "Cover Photo",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),

                InkWell(
                  onTap: () async {
                    final pickedPhoto =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedPhoto != null) {
                      serviceProvider.setCoverPhoto(pickedPhoto);
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: isDarkMode ? [] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: serviceProvider.coverPhoto == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(IconlyLight.image,
                                      size: 32,
                                      color: isDarkMode ? Colors.white : AppTheme.primaryColor),
                                  const SizedBox(height: 16),
                                  Text('Add Cover Photo',
                                      style: GoogleFonts.inter(
                                        color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  const SizedBox(height: 8),
                                  Text('This will be the main image for your service',
                                      style: GoogleFonts.inter(
                                        color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                                        fontSize: 14,
                                      )),
                                ],
                              ),
                            )
                          : Stack(
                              children: [
                                Image.file(
                                  File(serviceProvider.coverPhoto!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: InkWell(
                                    onTap: () {
                                      // Use the new method to clear the cover photo
                                      serviceProvider.clearCoverPhoto();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Basic Service Information
                Text(
                  "Basic Information",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 16),

                // Service name field
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: isDarkMode ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
    child: TextField(
    controller: serviceProvider.nameController,
    style: GoogleFonts.inter(
    color: isDarkMode ? Colors.white : Colors.black87,
    ),
    decoration: InputDecoration(
    labelText: 'Service Name',
    labelStyle: GoogleFonts.inter(
    color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
    fontSize: 14,
    ),
    hintText: 'Enter your service name',
    hintStyle: GoogleFonts.inter(
    color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
    fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: InputBorder.none,
    ),
    ),
    ),
    const SizedBox(height: 16),

    // Service description field
    Container(
    decoration: BoxDecoration(
    color: isDarkMode ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isDarkMode
    ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade200,
    width: 1.5,
    ),
    boxShadow: isDarkMode ? [] : [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    child: TextField(
    controller: serviceProvider.descriptionController,
    style: GoogleFonts.inter(
    color: isDarkMode ? Colors.white : Colors.black87,
    ),
    maxLines: 5,
    minLines: 3,
    decoration: InputDecoration(
    labelText: 'Description',
    alignLabelWithHint: true,
    labelStyle: GoogleFonts.inter(
    color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
    fontSize: 14,
    ),
    hintText: 'Describe what you offer in detail',
    hintStyle: GoogleFonts.inter(
    color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
    fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: InputBorder.none,
    ),
    ),
    ),
    const SizedBox(height: 16),

    // Price field
    Container(
    decoration: BoxDecoration(
    color: isDarkMode ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isDarkMode
    ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade200,
    width: 1.5,
    ),
    boxShadow: isDarkMode ? [] : [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    child: TextField(
    controller: serviceProvider.priceController,
    style: GoogleFonts.inter(
    color: isDarkMode ? Colors.white : Colors.black87,
    ),
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
    labelText: 'Price (PKR)',
    labelStyle: GoogleFonts.inter(
    color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
    fontSize: 14,
    ),
    hintText: 'Enter the price for your service',
    hintStyle: GoogleFonts.inter(
    color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
    fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: InputBorder.none,
    ),
    ),
    ),

    const SizedBox(height: 32),

    // Location Section
    Text(
    "Location & Category",
    style: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
    ),
    ),
    const SizedBox(height: 16),

    // Category and City selection in the same row
    Row(
    children: [
    Expanded(
    child: Container(
    decoration: BoxDecoration(
    color: isDarkMode ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isDarkMode
    ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade200,
    width: 1.5,
    ),
    boxShadow: isDarkMode ? [] : [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    child: DropdownButtonFormField<String>(
      isExpanded: true, // Set this to prevent overflow
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.inter(
          color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: InputBorder.none,
      ),
      dropdownColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      value: serviceProvider.selectedCategory.isEmpty ? null : serviceProvider.selectedCategory,
      items: categoryProvider.categories.map((e) => DropdownMenuItem<String>(
        value: e.title,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Text(
            e.title!,
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )).toList(),
      onChanged: (value) => serviceProvider.setCategory(value!),
      hint: Text(
        'Select Category',
        style: GoogleFonts.inter(
          color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
        ),
      ),
    icon: Icon(
    Icons.arrow_drop_down_rounded,
    color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
    ),
    ),
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Container(
    decoration: BoxDecoration(
    color: isDarkMode ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isDarkMode
    ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade200,
    width: 1.5,
    ),
    boxShadow: isDarkMode ? [] : [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    child: DropdownButtonFormField<String>(
      isExpanded: true, // Set this to prevent overflow
      decoration: InputDecoration(
        labelText: 'City',
        labelStyle: GoogleFonts.inter(
          color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: InputBorder.none,
      ),
      dropdownColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      value: serviceProvider.selectedCity.isEmpty ? null : serviceProvider.selectedCity,
      items: cityProvider.cities.map((e) => DropdownMenuItem<String>(
        value: e.name,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Text(
            e.name!,
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )).toList(),
      onChanged: (value) => serviceProvider.setCity(value!),
      hint: Text(
        'Select City',
        style: GoogleFonts.inter(
          color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
        ),
      ),
    icon: Icon(
    Icons.arrow_drop_down_rounded,
    color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
    ),
    ),
    ),
    ),
    ],
    ),

    const SizedBox(height: 32),

    // Time Selection Section
    Text(
    "Service Hours",
    style: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
    ),
    ),
    const SizedBox(height: 16),

    // Start and End Time
    Row(
    children: [
    Expanded(
    child: InkWell(
    onTap: () async {
    await _selectTime(
    context,
    controller: serviceProvider.startTimeController,
    onTimeSelected: (DateTime dateTime) {
      setState(() {
        _startTime = dateTime;
      });
    },
    );
    },
    child: Container(
    decoration: BoxDecoration(
    color: isDarkMode ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isDarkMode
    ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade200,
    width: 1.5,
    ),
    boxShadow: isDarkMode ? [] : [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    child: Row(
    children: [
    Icon(
    IconlyLight.time_circle,
    size: 20,
    color: isDarkMode ? Colors.white : AppTheme.primaryColor,
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Start Time',
    style: GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    serviceProvider.startTimeController.text.isEmpty
    ? 'Select'
        : serviceProvider.startTimeController.text,
    style: GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: isDarkMode ? Colors.white : Colors.black87,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: InkWell(
    onTap: () async {
    await _selectTime(
    context,
    controller: serviceProvider.endTimeController,
    onTimeSelected: (DateTime dateTime) {
      setState(() {
        _endTime = dateTime;
      });
    },
    );
    },
    child: Container(
    decoration: BoxDecoration(
    color: isDarkMode ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isDarkMode
    ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade200,
    width: 1.5,
    ),
    boxShadow: isDarkMode ? [] : [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    child: Row(
    children: [
    Icon(
    IconlyLight.time_circle,
    size: 20,
    color: isDarkMode ? Colors.white : AppTheme.primaryColor,
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'End Time',
    style: GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    serviceProvider.endTimeController.text.isEmpty
    ? 'Select'
        : serviceProvider.endTimeController.text,
    style: GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: isDarkMode ? Colors.white : Colors.black87,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ],
    ),

    const SizedBox(height: 32),

    // Service Availability Section
    Text(
    "Service Status",
    style: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
    ),
    ),
    const SizedBox(height: 16),

    Container(
    decoration: BoxDecoration(
    color: isDarkMode ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: isDarkMode
    ? Colors.white.withOpacity(0.1)
        : Colors.grey.shade200,
    width: 1.5,
    ),
    boxShadow: isDarkMode ? [] : [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
    children: [
    Icon(
    serviceProvider.isAvailable ? IconlyBold.tick_square : IconlyLight.close_square,
    size: 20,
    color: isDarkMode ? Colors.white : AppTheme.primaryColor,
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Service Availability',
    style: GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    serviceProvider.isAvailable ? 'Your service will be visible to customers' : 'Your service will be hidden from customers',
    style: GoogleFonts.inter(
    fontSize: 12,
    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
    ),
    ),
    ],
    ),
    ),
    Switch(
    value: serviceProvider.isAvailable,
    onChanged: (value) => serviceProvider.toggleAvailability(value),
    activeColor: AppTheme.primaryColor,
    activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
    inactiveThumbColor: isDarkMode ? Colors.white70 : Colors.grey.shade400,
    inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.grey.shade300,
    ),
    ],
    ),
    ),

    const SizedBox(height: 40),

    // Save Button
    Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
      onTap: _isLoading ? null : () async {
        if (_validateInputs(serviceProvider)) {
          // Set loading state
          setState(() {
            _isLoading = true;
          });

          try {
            final serviceData = CreateService(
              serviceName: serviceProvider.nameController.text.trim(),
              description: serviceProvider.descriptionController.text.trim(),
              price: int.parse(serviceProvider.priceController.text.trim()),
              startTime: _startTime.toString(),
              endTime: _endTime.toString(),
              categoryId: categoryProvider.getCategoryIdByName(
                serviceProvider.selectedCategory),
              cityId: cityProvider.getCityIdByName(
                serviceProvider.selectedCity),
              city: serviceProvider.selectedCity,
              isAvailable: serviceProvider.isAvailable,
            );

            bool result = await serviceProvider.createServiceWithCoverPhoto(
              serviceData,
              serviceProvider.coverPhoto!.path,
            );

            if (result) {
              showCustomSnackBar(
                context,
                "Service Created Successfully!",
                Colors.green
              );
              Navigator.pop(context);
            } else {
              showCustomSnackBar(
                context,
                serviceProvider.errorMessage ?? "Unknown error occurred.",
                Colors.red
              );
            }
          } catch (e) {
            showCustomSnackBar(
              context,
              'An error occurred: ${e.toString()}',
              Colors.red
            );
          } finally {
            // Reset loading state if we're still mounted
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
          showCustomSnackBar(
            context,
            'Please fill all fields and add a cover photo.',
            Colors.red
          );
        }
      },
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Create Service",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
      ),
      ),
      ),

      // Bottom spacing
      const SizedBox(height: 40),
      ],
      ),
      );
    },
    ),
    ),
    );
  }

  // Validation Method
  bool _validateInputs(ServiceProvider serviceProvider) {
    return serviceProvider.coverPhoto != null &&
        serviceProvider.nameController.text.trim().isNotEmpty &&
        serviceProvider.descriptionController.text.trim().isNotEmpty &&
        serviceProvider.priceController.text.trim().isNotEmpty &&
        serviceProvider.startTimeController.text.trim().isNotEmpty &&
        serviceProvider.endTimeController.text.trim().isNotEmpty &&
        serviceProvider.selectedCategory.isNotEmpty &&
        serviceProvider.selectedCity.isNotEmpty;
  }
}