import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/orders/orders_provider.dart';
import 'package:e_commerce/screens/orders/order_detail_screen.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/date_and_time_formatting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../utils/info_helper_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).clearOrders();
      Provider.of<OrderProvider>(context, listen: false).fetchMyOrders();
    });
  }

  // Helper method to return the correct message based on the user role
  String _getHelperMessage(String role) {
    if (role == "service_provider") {
      return "You are viewing orders from customers who have purchased your services. Switch to customer mode to see your personal orders.";
    } else if (role == "customer") {
      return "You are viewing your orders as a customer. Switch to seller mode to manage your service requests.";
    } else {
      return "Explore available orders and services.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final authProvider = context.watch<AuthenticationProvider>();
    final role = authProvider.user?.role?.title ?? "customer";
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          role == "service_provider" ? "Received Orders" : "My Orders",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : AppTheme.accentText),
        ),
        backgroundColor: Colors.transparent,
        actions: [
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
                        _getHelperMessage(role),
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
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500, 
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer2<OrderProvider, AuthenticationProvider>(
        builder: (context, orderProvider, authProvider, child) {
          final isCustomer = authProvider.user?.role?.title == 'customer';
          
          if (orderProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: AppTheme.secondaryColor,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading your orders...",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = orderProvider.orders;

          if (orders == null || orders.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconlyLight.document,
                    size: 64,
                    color: AppTheme.mediumGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCustomer 
                      ? 'You haven\'t placed any orders yet' 
                      : 'You haven\'t received any orders yet',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          final filteredOrders = orderProvider.selectedFilter == "All"
              ? orders.data
              : orders.data
                  .where(
                    (order) => order.orderStatus == orderProvider.selectedFilter,
                  )
                  .toList()
                ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
                
          if (filteredOrders.isEmpty) {
            return Column(
              children: [
                // Filter chips
                _buildFilterChips(orderProvider),
                
                // Empty state for filtered results
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconlyLight.filter,
                          size: 48,
                          color: AppTheme.mediumGrey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No ${orderProvider.selectedFilter.toLowerCase()} orders',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try selecting a different filter',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : AppTheme.mediumGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              _buildFilterChips(orderProvider),
              
              // Order summary section (totals)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black12 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                  border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Total',
                      filteredOrders.length.toString(),
                      IconlyLight.document,
                      isDarkMode,
                    ),
                    _buildSummaryItem(
                      'Pending',
                      filteredOrders.where((order) => order.orderStatus == 'pending').length.toString(),
                      IconlyLight.time_circle,
                      isDarkMode,
                    ),
                    _buildSummaryItem(
                      'Completed',
                      filteredOrders.where((order) => order.orderStatus == 'completed').length.toString(),
                      IconlyLight.tick_square,
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              
              // Orders list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order, isDarkMode, isCustomer);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(OrderProvider orderProvider) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          buildFilterChip("All"),
          buildFilterChip("pending"),
          buildFilterChip("processing"),
          buildFilterChip("completed"),
          buildFilterChip("cancelled"),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon, bool isDarkMode) {
    return Column(
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.white : AppTheme.darkGrey,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppTheme.darkGrey,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDarkMode ? Colors.white.withOpacity(0.9) : AppTheme.mediumGrey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildOrderCard(order, bool isDarkMode, bool isCustomer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: isDarkMode ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
        elevation: isDarkMode ? 0 : 1,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius_md),
          onTap: () {
            Navigator.push(
              context,
              SlidePageRoute(
                page: OrderDetailsScreen(order: order, isServiceProvider: !isCustomer),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(AppTheme.radius_lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with service image, name and status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radius_md),
                      child: CachedNetworkImage(
                        imageUrl: order.service.coverPhoto,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.lightGrey,
                          child: Center(
                            child: Icon(
                              IconlyLight.image,
                              color: AppTheme.mediumGrey,
                              size: 24,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.lightGrey,
                          child: Center(
                            child: Icon(
                              IconlyLight.danger,
                              color: AppTheme.mediumGrey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Service details
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
                          const SizedBox(height: 4),
                          
                          // Counterparty - either provider or customer depending on role
                          Row(
                            children: [
                              Icon(
                                isCustomer ? IconlyLight.profile : IconlyLight.user,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  isCustomer 
                                    ? "Provider: ${order.serviceProvider}" 
                                    : "Customer: ${order.customer}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDarkMode ? getStatusColor(order.orderStatus).withOpacity(0.3) : getStatusColor(order.orderStatus).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radius_md),
                        border: Border.all(color: getStatusColor(order.orderStatus), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(order.orderStatus),
                            size: 12,
                            color: getStatusColor(order.orderStatus),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.orderStatus.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: getStatusColor(order.orderStatus),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 24),
                
                // Order details section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black12 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppTheme.radius_md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Order ID
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ORDER ID",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDarkMode ? Colors.white60 : AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "#${order.id?.substring(0, 8) ?? "N/A"}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      
                      // Order date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DATE",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDarkMode ? Colors.white60 : AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(order.placedAt.toString()),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      
                      // Order price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "AMOUNT",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDarkMode ? Colors.white60 : AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${order.orderPrice}",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppTheme.secondaryColor.withOpacity(0.9) : AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget buildFilterChip(String label) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final selectedFilter = Provider.of<OrderProvider>(context).selectedFilter;
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label == "All" ? "All Orders" : label.toUpperCase(),
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
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        selectedColor: AppTheme.secondaryColor,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius_circle),
        ),
        onSelected: (bool selected) {
          if (selected) {
            Provider.of<OrderProvider>(context, listen: false).setFilter(label);
          }
        },
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "processing":
        return AppTheme.info;
      case "pending":
        return AppTheme.warning;
      case "cancelled":
        return AppTheme.error;
      case "completed":
        return AppTheme.success;
      default:
        return Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey;
    }
  }
  
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "processing":
        return IconlyLight.time_circle;
      case "pending":
        return IconlyLight.time_circle;
      case "cancelled":
        return IconlyLight.close_square;
      case "completed":
        return IconlyLight.tick_square;
      default:
        return IconlyLight.info_circle;
    }
  }
}
