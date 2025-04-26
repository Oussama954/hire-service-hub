import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/common/snakbar/custom_snakbar.dart';
import 'package:e_commerce/models/orders/create_order_model.dart';
import 'package:e_commerce/models/orders/order_model.dart';
import 'package:e_commerce/models/service/fetch_signle_service_model.dart';
import 'package:e_commerce/providers/orders/orders_provider.dart';
import 'package:e_commerce/screens/orders/order_success_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class BookOrderScreen extends StatefulWidget {
  final SpecificService? service;

  const BookOrderScreen({super.key, required this.service});

  @override
  State<BookOrderScreen> createState() => _BookOrderScreenState();
}

class _BookOrderScreenState extends State<BookOrderScreen> {
  final TextEditingController additionalNotesController =
      TextEditingController();
  final TextEditingController selectedDateController = TextEditingController();

  DateTime? selectedOrderDate;

  Future<void> selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    
    // Allow booking from today itself (current date)
    final DateTime firstDate = currentDate;
    final DateTime initialDate = currentDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100), // Arbitrary future date
    );

    if (pickedDate != null) {
      setState(() {
        selectedOrderDate = pickedDate;
        selectedDateController.text = pickedDate
            .toLocal()
            .toString()
            .split(' ')[0]; // Format as YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Order',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white70 : AppTheme.darkGrey.withOpacity(0.7),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Service Details",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black12 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                  boxShadow: isDarkMode ? [] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Price",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Inc. all taxes",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Rs${widget.service?.price ?? 'N/A'}",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? AppTheme.primaryColor : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Select Order Date",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black12 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                    boxShadow: isDarkMode ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconlyLight.calendar,
                        size: 24,
                        color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDateController.text.isEmpty 
                              ? "Select a date" 
                              : selectedDateController.text,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: selectedDateController.text.isEmpty
                                ? (isDarkMode ? Colors.white38 : Colors.grey.shade500)
                                : (isDarkMode ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode ? Colors.white30 : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Additional Notes (Optional)",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black12 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
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
                  controller: additionalNotesController,
                  style: GoogleFonts.inter(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Any special instructions here...",
                    hintStyle: GoogleFonts.inter(
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                      if (selectedOrderDate == null) {
                        showCustomSnackBar(
                          context,
                          "Please select a valid order date!",
                          Colors.red,
                        );
                        return;
                      }



                      final order = Order(
                        orderDate: selectedOrderDate.toString(),
                        serviceId: widget.service!.id!,
                        additionalNotes: additionalNotesController.text,
                        paymentMethod: "cod",
                        orderPrice: widget.service?.price.toString(),
                      );

                      final CreateOrderResponse? orderDetails =
                          await orderProvider.bookOrder(order);

                      if (orderProvider.errorMessage != null) {
                        showCustomSnackBar(
                          context,
                          orderProvider.errorMessage!,
                          Colors.red,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          SlidePageRoute(
                            page: OrderConfirmationScreen(
                              orderDetails: orderDetails,
                            ),
                          ),
                        );
                        showCustomSnackBar(
                          context,
                          "Order booked successfully!",
                          Colors.green,
                        );
                      }
                    },
                    child: orderProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Confirm Booking',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
