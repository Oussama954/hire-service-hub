import 'package:e_commerce/repository/reviews/reviews_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewsProvider extends ChangeNotifier {
  final ReviewsRepository _reviewRepository = ReviewsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<http.Response> submitReview({
    required String serviceId,
    required String reviewMessage,
    required double rating,
    required String orderId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _reviewRepository.createReview(
        orderId: orderId,
        serviceId: serviceId,
        reviewMessage: reviewMessage,
        rating: rating,
      );
      
      // Log the response for debugging
      print('Review submission response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('Error submitting review: $e');
      rethrow; // Rethrow to let the UI handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> deleteReview(String reviewId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _reviewRepository.deleteReview(reviewId);
      return response;
    } catch (e) {
      print(e);
      throw Exception('Failed to delete review: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
