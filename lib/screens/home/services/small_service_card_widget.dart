import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/models/service/service_model.dart';
import 'package:e_commerce/screens/service/service_detail_screen.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SmallServiceCard extends StatelessWidget {
  final ServiceModel service;

  const SmallServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final cardBackgroundColor = isDarkMode 
      ? Colors.black : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: ServiceDetailsScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
        child: Container(
          decoration: BoxDecoration(
            color: cardBackgroundColor,
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
              // Image container with gradient overlay
              Stack(
                children: [
                  // Service image with taller aspect ratio
                  AspectRatio(
                    aspectRatio: 16 / 11, // Changed from 16/9 to make the image taller
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radius_lg),
                        topRight: Radius.circular(AppTheme.radius_lg),
                      ),
                      child: (service.coverPhoto?.trim().isNotEmpty ?? false)
                        ? CachedNetworkImage(
                            imageUrl: service.coverPhoto!.trim(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDarkMode ? Colors.black38 : Colors.grey.shade200,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDarkMode ? Colors.black38 : Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                                  size: 32,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: isDarkMode ? Colors.black38 : Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                                size: 32,
                              ),
                            ),
                          ),
                    ),
                  ),
                  
                  // Gradient overlay for text readability
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radius_lg),
                        topRight: Radius.circular(AppTheme.radius_lg),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: const [0.6, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Price badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "₹${service.price}",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  
                  // Location badge
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.city ?? 'Location',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Availability badge
                  if (service.isAvailable ?? false)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Available",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Service details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service name with constrained width for consistent truncation
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        service.serviceName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppTheme.darkGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Description with more aggressive truncation
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        service.description,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.3,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        ),
                        maxLines: 1, // More aggressive truncation
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Provider info
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            service.user?.firstName ?? "Service Provider",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white70 : AppTheme.darkGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "View",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward,
                                size: 12,
                                color: isDarkMode ? Colors.white70 : AppTheme.primaryColor,
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
    );
  }
}
