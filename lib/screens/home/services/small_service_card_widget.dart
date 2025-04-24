import 'package:carded/carded.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/models/service/service_model.dart';
import 'package:e_commerce/screens/service/service_detail_screen.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';

class SmallServiceCard extends StatelessWidget {
  final ServiceModel service;

  const SmallServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Navigate to service details page
        Navigator.push(
          context,
          SlidePageRoute(
            page: ServiceDetailsScreen(service: service),
          ),
        );
      },
      child: CardyContainer(
        color: isDarkMode ? AppTheme.fdarkBlue : Colors.white,
        spreadRadius: 0,
        blurRadius: 1,
        borderRadius: BorderRadius.circular(16),
        shadowColor: isDarkMode ? AppTheme.fdarkBlue : Colors.grey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image (Smaller height)
            (service.coverPhoto?.trim().isNotEmpty ?? false)
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    child: Image.network(
                      service.coverPhoto!.trim(),
                      width: double.infinity,
                      height: 100, // Reduced height
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            width: double.infinity,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  )
                : ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    child: Image.network(
                      'https://via.placeholder.com/300x100.png?text=No+Image', // Fallback network image
                      width: double.infinity,
                      height: 100, // Reduced height
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            width: double.infinity,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
            // Service Details (Smaller fonts)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceName,
                    style: const TextStyle(
                      fontSize: 14, // Smaller font
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(fontSize: 12), // Smaller font
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  //const SizedBox(height: 6),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       service.city,
                  //       style: const TextStyle(
                  //         fontSize: 12, // Smaller font
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //     Text(
                  //       "Rs${service.price}",
                  //       style: const TextStyle(
                  //         fontSize: 12, // Smaller font
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
