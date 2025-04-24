import 'package:cached_network_image/cached_network_image.dart';
import 'package:carded/carded.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/orders/orders_provider.dart';
import 'package:e_commerce/screens/orders/order_detail_screen.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:e_commerce/utils/date_and_time_formatting.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../utils/info_helper_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
      return "You are currently in seller mode. You can view orders from customers who have bought your services. If you'd like to view your own orders as a customer, switch to customer mode.";
    } else if (role == "customer") {
      return "You are currently in customer mode. You can view the orders you have made from service providers. If you'd like to manage services as a seller, switch to seller mode.";
    } else {
      return "Explore available orders and services.";
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;
    final authProvider = context.watch<
        AuthenticationProvider>(); // Assuming this provides user role info
    final role = authProvider.user?.role?.title ?? "customer"; // Get user role
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          role == "service_provider" ? "Received Orders" : "My Orders",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InfoWidget(
                  elevation: 6,
                  infoTextStyle: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 14),
                  infoText: _getHelperMessage(role),
                  iconData: Icons.help,
                  iconColor: Colors.blue)),
        ],
      ),
      body: Consumer2<OrderProvider, AuthenticationProvider>(
        builder: (context, orderProvider, authProvider, child) {
          bool isCustomer = authProvider.user?.role?.title == 'customer';
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = orderProvider.orders;

          if (orders == null || orders.data.isEmpty) {
            return const Center(child: Text('No orders available.'));
          }

          final filteredOrders = orderProvider.selectedFilter == "All"
              ? orders.data
              : orders.data
                  .where(
                    (order) =>
                        order.orderStatus == orderProvider.selectedFilter,
                  )
                  .toList()
            ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

          return Column(
            children: [
              // Horizontal Scrollable Chips
              Container(
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildFilterChip("All"),
                    buildFilterChip("processing"),
                    buildFilterChip("pending"),
                    buildFilterChip("cancelled"),
                    buildFilterChip("completed"),
                  ],
                ),
              ),
              // Orders List
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: Text(
                          "No ${orderProvider.selectedFilter.toLowerCase()} order available yet.",
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  SlidePageRoute(
                                      page: OrderDetailsScreen(
                                    order: order,
                                    isServiceProvider:
                                        authProvider.user?.role!.title ==
                                                "service_provider"
                                            ? true
                                            : false,
                                  )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Material(
                                elevation: 1,
                                color: isDarkMode ? Colors.grey[850] : Colors.white,
                                shadowColor: isDarkMode ? Colors.black54 : Colors.grey,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top row with service image and details
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Service Image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: SizedBox(
                                              width: 80,
                                              height: 60,
                                              child: order.service?.coverPhoto != null &&
                                                      order.service!.coverPhoto.toString().isNotEmpty
                                                  ? Image.network(
                                                      order.service!.coverPhoto.toString(),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/images/content-writer.webp',
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/images/content-writer.webp',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Service details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        order.service?.serviceName ?? "Service",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  order.service?.description ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Status row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Customer info
                                          Expanded(
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: CachedNetworkImage(
                                                    imageUrl: isCustomer
                                                        ? authProvider.user?.profilePicture ??
                                                            'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg'
                                                        : order.customer?.profilePicture ??
                                                            "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg",
                                                    width: 30,
                                                    height: 30,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    isCustomer
                                                        ? "${authProvider.user?.firstName} ${authProvider.user?.lastName}"
                                                        : "${order.customer?.firstName ?? ""} ${order.customer?.lastName ?? ""}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Order status
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(order.orderStatus),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              order.orderStatus.toLowerCase(),
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Bottom row with price and date
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Price: \$${order.orderPrice}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? Colors.white : Colors.green[700],
                                            ),
                                          ),
                                          Text(
                                            "${order.placedAt.day}-${order.placedAt.month}-${order.placedAt.year}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildFilterChip(String label) {
    Brightness brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

    final selectedFilter = Provider.of<OrderProvider>(context).selectedFilter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        label: Text(label.toUpperCase()),
        selected: selectedFilter == label,
        onSelected: (isSelected) {
          Provider.of<OrderProvider>(context, listen: false).setFilter(label);
        },
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "processing":
        return Colors.grey;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      case "completed":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
