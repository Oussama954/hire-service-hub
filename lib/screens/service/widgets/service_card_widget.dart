import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/models/service/service_model.dart';
import 'package:e_commerce/screens/service/service_detail_screen.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});
  
  // Helper method to get the provider's full name or fallback to "Provider"
  String _getProviderName(User user) {
    if (user.firstName != null && user.lastName != null) {
      return "${user.firstName} ${user.lastName}";
    } else if (user.firstName != null) {
      return user.firstName!;
    } else if (user.lastName != null) {
      return user.lastName!;
    } else {
      return "Provider";
    }
  }
  
  // Helper method to get the provider's initial or fallback to "P"
  String _getProviderInitial(User user) {
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      return user.firstName![0].toUpperCase();
    } else if (user.lastName != null && user.lastName!.isNotEmpty) {
      return user.lastName![0].toUpperCase();
    } else {
      return "P";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: isDarkMode ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
        elevation: isDarkMode ? 0 : 1,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              SlidePageRoute(page: ServiceDetailsScreen(service: service)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(AppTheme.radius_lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image with overlays
                AspectRatio(
                  aspectRatio: 16/9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover Image
                      (service.coverPhoto?.trim().isNotEmpty ?? false)
                        ? CachedNetworkImage(
                            imageUrl: service.coverPhoto!.trim(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                                strokeWidth: 3,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: isDarkMode ? Colors.white38 : AppTheme.mediumGrey,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                            child: Icon(
                              IconlyBold.image,
                              size: 50,
                              color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                            ),
                          ),
                      
                      // Dark gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                      
                      // Overlay information
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Location with icon
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      IconlyBold.location,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      service.city ?? 'Location not specified',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(color: Colors.black, blurRadius: 3)
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                              
                            // Price Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                "₹${service.price ?? '0'}",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Availability indicator
                      if (service.isAvailable == true)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Available",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Service Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.serviceName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : AppTheme.accentText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Service hours
                          if (service.startTime != null && service.endTime != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${service.startTime} - ${service.endTime}",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Description
                      Text(
                        service.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.4,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      // Bottom section with service provider (if available) and details button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Show provider info if available
                          if (service.user != null && (service.user?.firstName != null || service.user?.lastName != null))
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                  child: Text(
                                    _getProviderInitial(service.user!),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getProviderName(service.user!),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            
                          // View details button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(AppTheme.radius_md),
                              border: Border.all(color: isDarkMode ? Colors.white24 : Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "View Details",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  IconlyLight.arrow_right_2,
                                  size: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ],
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
    );
  }
}
