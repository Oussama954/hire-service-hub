import 'package:e_commerce/models/orders/create_order_model.dart';
import 'package:e_commerce/screens/bottom_navigation_bar.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/date_and_time_formatting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final CreateOrderResponse? orderDetails;

  const OrderConfirmationScreen({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      IconlyBold.tick_square,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Success message
              Text(
                "Order Placed Successfully!",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "You can track and manage this order in your orders section",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Order details card
              Container(
                width: double.infinity,
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Summary",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DetailRow(
                        icon: IconlyLight.calendar,
                        label: "Order Date",
                        value: formatTime(orderDetails!.data!.orderDate.toString()),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: IconlyLight.wallet,
                        label: "Payment Method",
                        value: orderDetails?.data?.paymentMethod == "cod" ? "Cash on Delivery" : 
                               orderDetails?.data?.paymentMethod.toUpperCase() ?? "N/A",
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: IconlyLight.buy,
                        label: "Total Amount",
                        value: "Rs. ${orderDetails?.data?.orderPrice ?? "N/A"}",
                        isDarkMode: isDarkMode,
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Action button
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
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BottomNavigationBarScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Continue Shopping',
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
    ));
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;
  final bool isHighlighted;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppTheme.primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1)
                : isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isHighlighted
                ? AppTheme.primaryColor
                : isDarkMode
                    ? Colors.white70
                    : Colors.grey[800],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlighted
                      ? AppTheme.primaryColor
                      : isDarkMode
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
