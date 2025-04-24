import 'dart:convert';
import 'package:e_commerce/models/orders/create_order_model.dart';
import 'package:e_commerce/models/orders/get_my_orders.dart';
import 'package:e_commerce/models/orders/order_model.dart';
import 'package:e_commerce/services/orders/orders_service.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  final OrderService _orderService = OrderService();

  Future<CreateOrderResponse?> bookOrder(Order order) async {
    try {
      final response = await _orderService.bookOrder(order);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success status codes (2xx)
        print('Booking successful: ${response.body}');
        return CreateOrderResponse.fromMap(json.decode(response.body));
      } else {
        // Get more detailed error information
        String errorMessage = 'Unknown error';
        try {
          final errorJson = json.decode(response.body);
          print('Server error response: $errorJson');
          
          // Check if the error has a specific format
          if (errorJson.containsKey('errors') && errorJson['errors'] is List && errorJson['errors'].isNotEmpty) {
            // Format: { "errors": [{"msg": "error message", ...}] }
            final firstError = errorJson['errors'][0];
            errorMessage = firstError['msg'] ?? firstError['message'] ?? response.body;
          } else {
            // Format: { "message": "error message" }
            errorMessage = errorJson['message'] ?? errorJson['error'] ?? response.body;
          }
        } catch (parseError) {
          // If can't parse JSON, use raw response
          errorMessage = response.body;
        }
        
        throw Exception('Server error (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('Exception during booking: $e');
      // Just forward the exception without wrapping it in another Exception
      // This allows the original error details to be preserved
      rethrow;
    }
  }

  Future<GetMyOrders?> fetchOrders() async {
    try {
      final response = await _orderService.getMyOrders();
      
      print('Orders API Response status: ${response.statusCode}');
      print('Orders API Response body (beginning): ${response.body.substring(0, 200)}...');
      
      if (response.statusCode == 200) {
        return GetMyOrders.fromJson(json.decode(response.body));
      } else {
        print('Failed to fetch orders: ${response.statusCode}');
        print('Error response: ${response.body}');
        throw Exception("Failed to fetch orders: ${response.body}");
      }
    } catch (e) {
      print('Exception in fetchOrders: $e');
      rethrow;
    }
  }

  Future<http.Response> cancelOrder({
    required String orderId,
    required String cancellationReason,
  }) {
    return _orderService.cancelOrder(
      orderId: orderId,
      cancellationReason: cancellationReason,
    );
  }

  Future<http.Response> updateOrder({
    required String orderId,
    required String orderDate,
    required String additionalNotes,
  }) {
    return _orderService.updateOrder(
      orderId: orderId,
      orderDate: orderDate,
      additionalNotes: additionalNotes,
    );
  }

  Future<http.Response> acceptOrder(String orderId) {
    return _orderService.updateOrderStatus(
      orderId: orderId,
      orderStatus: "accepted",
    );
  }

  Future<http.Response> rejectOrder(String orderId) {
    return _orderService.updateOrderStatus(
      orderId: orderId,
      orderStatus: "cancelled",
    );
  }

  Future<http.Response> completeOrder(String orderId) {
    return _orderService.updateOrderStatus(
      orderId: orderId,
      orderStatus: "completed",
    );
  }
}
