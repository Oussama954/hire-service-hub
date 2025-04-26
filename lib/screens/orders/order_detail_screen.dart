import 'dart:convert';

import 'package:carded/carded.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/common/snakbar/custom_snakbar.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/orders/orders_provider.dart';
import 'package:e_commerce/screens/orders/order_update_screen.dart';
import 'package:e_commerce/screens/orders/review_order_dialog.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/models/orders/get_my_orders.dart';
import 'package:e_commerce/utils/date_and_time_formatting.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Datum order;
  final bool isServiceProvider;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.isServiceProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.accentText,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: OrderCard(order: order, isServiceProvider: isServiceProvider),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Datum order;
  final bool isServiceProvider;
  
  const OrderCard({
    super.key,
    required this.order,
    required this.isServiceProvider,
  });
  
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header with status and price
          Container(
            padding: const EdgeInsets.all(20.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ORDER ID",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "#${order.id.substring(0, 8)}",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "ORDER DATE",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatDate(order.placedAt.toString()),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Order Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? getStatusColor(order.orderStatus).withOpacity(0.2) 
                            : getStatusColor(order.orderStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius_md),
                        border: Border.all(color: getStatusColor(order.orderStatus), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(order.orderStatus),
                            size: 14,
                            color: getStatusColor(order.orderStatus),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.orderStatus.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: getStatusColor(order.orderStatus),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? AppTheme.secondaryColor.withOpacity(0.2) 
                            : AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        '₹${order.orderPrice}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Service details
          Container(
            padding: const EdgeInsets.all(20.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Service Information",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppTheme.accentText,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Service details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radius_md),
                      child: Image.network(
                        order.service.coverPhoto,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                          child: Icon(Icons.image_outlined, 
                            size: 30,
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.service.serviceName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (order.serviceProvider != null)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.person_outline, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Provider: ${order.serviceProvider!.firstName} ${order.serviceProvider!.lastName}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (order.customer != null)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.account_circle_outlined, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Customer: ${order.customer!.firstName} ${order.customer!.lastName}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Payment and timing info
                _buildInfoGrid(context, isDarkMode, order),
                
                if (order.additionalNotes != null && order.additionalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description_outlined, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Additional Notes",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.additionalNotes!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (order.orderStatus == "cancelled" && order.cancellationReason != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.error_outline, size: 18, color: AppTheme.error),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cancellation Reason",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.cancellationReason!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Actions section
          if (_shouldShowActions(order, isServiceProvider))
            Container(
              padding: const EdgeInsets.all(20.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Actions",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppTheme.accentText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(context, order),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  bool _shouldShowActions(Datum order, bool isServiceProvider) {
    if (!isServiceProvider) {
      return order.orderStatus == "completed" || order.orderStatus == "pending";
    } else {
      return order.orderStatus == "pending" || 
             order.orderStatus == "processing" || 
             order.orderStatus == "completed";
    }
  }
  
  Widget _buildInfoGrid(BuildContext context, bool isDarkMode, Datum order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Details",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.accentText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black12 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppTheme.radius_md),
            border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Payment information row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Payment Status',
                      order.paymentStatus.toUpperCase(),
                      isDarkMode,
                      IconlyLight.wallet,
                      order.paymentStatus.toLowerCase() == 'paid' ? AppTheme.success : AppTheme.info,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Payment Method',
                      order.paymentMethod.toUpperCase(),
                      isDarkMode,
                      IconlyLight.swap,
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date information row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Order Date',
                      formatDate(order.orderDate.toString()),
                      isDarkMode,
                      IconlyLight.calendar,
                      AppTheme.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Order Time',
                      formatTime(order.placedAt.toString()),
                      isDarkMode,
                      IconlyLight.time_circle,
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem(String label, String value, bool isDarkMode, IconData icon, Color accentColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: accentColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  

  Widget _buildActionButtons(BuildContext context, Datum order) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, child) {
      Widget actionWidget;
      
      if (!isServiceProvider) {
        // Customer actions
        if (order.orderStatus == "completed") {
          actionWidget = _ActionButton(
            label: 'Give Review',
            icon: IconlyLight.star,
            color: AppTheme.success,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    ReviewDialog(serviceId: order.service.id, orderId: order.id),
              );
            },
          );
        } else if (order.orderStatus == "pending") {
          actionWidget = _ActionButton(
            label: 'Cancel Order',
            icon: IconlyLight.close_square,
            color: AppTheme.error,
            onPressed: () {
              _showCancelOrderDialog(context, order);
            },
          );
        } else {
          actionWidget = Container(); // No action for other statuses
        }
      } else {
        // Service provider actions
        if (order.orderStatus == "pending") {
          actionWidget = Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Accept Order',
                  icon: IconlyLight.tick_square,
                  color: AppTheme.success,
                  onPressed: () async {
                    try {
                      final response = await orderProvider.acceptOrder(order.id);
                      if (response!.statusCode == 200) {
                        orderProvider.fetchMyOrders();
                        final responseData = jsonDecode(response.body);
                        showCustomSnackBar(
                            context, responseData['message'], Colors.green);
                        Navigator.pop(context); // Close the dialog
                      } else {
                        final responseData = jsonDecode(response.body);
                        showCustomSnackBar(
                            context,
                            responseData['message'] ?? "An error occurred.",
                            Colors.red);
                      }
                    } catch (e) {
                      showCustomSnackBar(
                          context, "An error occurred: $e", Colors.red);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Reject Order',
                  icon: IconlyLight.close_square,
                  color: AppTheme.error,
                  onPressed: () async {
                    try {
                      final response = await orderProvider.rejectOrder(order.id);
                      if (response!.statusCode == 200) {
                        orderProvider.fetchMyOrders();
                        final responseData = jsonDecode(response.body);
                        showCustomSnackBar(
                            context, responseData['message'], Colors.green);
                        Navigator.pop(context); // Close the dialog
                      } else {
                        final responseData = jsonDecode(response.body);
                        showCustomSnackBar(
                            context,
                            responseData['message'] ?? "An error occurred.",
                            Colors.red);
                      }
                    } catch (e) {
                      showCustomSnackBar(
                          context, "An error occurred: $e", Colors.red);
                    }
                  },
                ),
              ),
            ],
          );
        } else if (order.orderStatus == "processing" || order.orderStatus == "accepted") {
          // Show complete button for both accepted and processing orders
          // This allows providers to complete orders manually before the automatic completion
          actionWidget = _ActionButton(
            label: 'Mark As Completed',
            icon: Icons.check_circle_outline,
            color: AppTheme.success,
            onPressed: () async {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  final isDarkMode = Theme.of(dialogContext).brightness == Brightness.dark;
                  return AlertDialog(
                    backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                    title: Text(
                      'Complete Order',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to mark this order as completed? This action cannot be undone.',
                      style: GoogleFonts.inter(
                        color: isDarkMode ? Colors.white70 : Colors.grey[800],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            color: isDarkMode ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          // Close confirmation dialog first
                          Navigator.pop(dialogContext);
                          
                          try {
                            final response = await orderProvider.completeOrder(order.id);
                            if (response!.statusCode == 200) {
                              orderProvider.fetchMyOrders();
                              final responseData = jsonDecode(response.body);
                              showCustomSnackBar(
                                  context, responseData['message'], Colors.green);
                              Navigator.pop(context); // Close the order details screen
                            } else {
                              final responseData = jsonDecode(response.body);
                              showCustomSnackBar(
                                  context,
                                  responseData['message'] ?? "An error occurred.",
                                  Colors.red);
                            }
                          } catch (e) {
                            showCustomSnackBar(
                                context, "An error occurred: $e", Colors.red);
                          }
                        },
                        child: Text(
                          'Complete Order',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        } else {
          actionWidget = Container(); // No action for other statuses
        }
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [actionWidget],
      );
    });
  }
  
  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return AppTheme.warning;
      case "accepted":
        return AppTheme.info;
      case "cancelled":
        return AppTheme.error;
      case "completed":
        return AppTheme.success;
      default:
        return Colors.grey;
    }
  }
  
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "processing":
        return IconlyLight.time_circle;
      case "pending":
        return IconlyLight.time_square;
      case "cancelled":
        return IconlyLight.close_square;
      case "completed":
        return IconlyLight.tick_square;
      default:
        return IconlyLight.info_circle;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(isDark ? 0.8 : 1.0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius_md),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label, 
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

void _showCancelOrderDialog(BuildContext context, Datum order) {
  final TextEditingController reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return _CancelOrderDialog(
          reasonController: reasonController, order: order);
    },
  );
}

class _CancelOrderDialog extends StatefulWidget {
  final TextEditingController reasonController;
  final Datum order;

  const _CancelOrderDialog({
    required this.reasonController,
    required this.order,
  });

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  String? _selectedReason;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  bool get isDarkMode => Brightness.dark == Theme.of(context).brightness;

  Future<void> _cancelOrderWithReason() async {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final reason = widget.reasonController.text.trim();

    if (reason.isEmpty) {
      showCustomSnackBar(
          context, "Please provide a cancellation reason.", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user is already in service_provider role
      bool isServiceProvider = authProvider.user?.role?.title == 'service_provider';
      bool didSwitchRole = false;
      
      // If not service provider, switch role
      if (!isServiceProvider) {
        final switchResult = await authProvider.switchRole();
        didSwitchRole = switchResult == 200;
        
        // Wait a moment for the token to be processed
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // Attempt to cancel the order
      final response = await provider.cancelOrder(
        orderId: widget.order.id,
        cancellationReason: reason,
      );
      
      // Switch back to customer role if we switched roles earlier
      if (didSwitchRole) {
        await authProvider.switchRole();
      }
      
      // Handle response
      if (response.statusCode == 200) {
        provider.fetchMyOrders();
        final responseData = jsonDecode(response.body);
        showCustomSnackBar(context, responseData['message'], Colors.green);
        Navigator.pop(context); // Close the dialog
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        showCustomSnackBar(context,
            responseData['message'] ?? "An error occurred.", Colors.red);
        Navigator.pop(context); // Close the dialog
      }
    } catch (e) {
      showCustomSnackBar(context, "An error occurred: $e", Colors.red);
      Navigator.pop(context); // Close the dialog
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isDarkMode ? 0 : 8,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(isDarkMode ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconlyBold.delete,
                    size: 20,
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "Cancel Order",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Description
            Text(
              "Please provide a reason for canceling this order:",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Text Field
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
                controller: widget.reasonController,
                style: GoogleFonts.inter(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Please explain why you're canceling...",
                  hintStyle: GoogleFonts.inter(
                    color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Back button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    "Back",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Cancel order button
                ElevatedButton(
                  onPressed: _isLoading ? null : _cancelOrderWithReason,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warning,
                    foregroundColor: Colors.white,
                    elevation: isDarkMode ? 0 : 2,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(IconlyLight.delete, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Cancel Order",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
