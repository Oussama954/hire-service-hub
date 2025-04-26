import 'dart:convert';

import 'package:e_commerce/common/snakbar/custom_snakbar.dart';
import 'package:e_commerce/providers/reviews/reviews_provider.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReviewDialog extends StatefulWidget {
  final String serviceId;
  final String orderId;

  const ReviewDialog(
      {required this.serviceId, super.key, required this.orderId});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _reviewController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    final reviewsProvider = Provider.of<ReviewsProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Rate Your Experience',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : AppTheme.darkGrey,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Animated Rating Bar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1, 
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            // Review Text Field
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                boxShadow: isDarkMode ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _reviewController,
                style: GoogleFonts.inter(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: GoogleFonts.inter(
                    color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Actions row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.white60 : Colors.grey,
                ),
                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14)),
              ),
              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: reviewsProvider.isLoading ? null : () async {
                  final reviewMessage = _reviewController.text.trim();
                  if (_rating == 0) {
                    showCustomSnackBar(
                        context, "Please give a star rating", Colors.red);
                    return;
                  }
                  if (reviewMessage.isEmpty) {
                    showCustomSnackBar(
                        context, "Please write a comment about your experience", Colors.red);
                    return;
                  }

                  try {
                    final response = await reviewsProvider.submitReview(
                      orderId: widget.orderId,
                      serviceId: widget.serviceId,
                      reviewMessage: reviewMessage,
                      rating: _rating,
                    );

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      // Show success message and close dialog
                      if (!context.mounted) return;
                      showCustomSnackBar(
                          context, "Review submitted successfully", Colors.green);
                      Navigator.pop(context, true); // Return true to indicate success
                    } else {
                      // Handle error case
                      if (!context.mounted) return;
                      Map<String, dynamic> responseData = {};
                      try {
                        responseData = jsonDecode(response.body);
                      } catch (e) {
                        // In case JSON parsing fails
                      }
                      final errorMessage = responseData['message'] ?? 
                                         responseData['error'] ?? 
                                         "Failed to submit review";
                      showCustomSnackBar(context, errorMessage, Colors.red);
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    showCustomSnackBar(context, "Error submitting review: $e", Colors.red);
                  }
                },
                child: reviewsProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Submit', style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
