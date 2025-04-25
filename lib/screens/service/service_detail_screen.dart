// ignore_for_file: use_build_context_synchronously

import 'package:carded/carded.dart';
import 'package:e_commerce/common/buttons/custom_elevated_button.dart';
import 'package:e_commerce/common/slide_page_routes/slide_page_route.dart';
import 'package:e_commerce/models/chat/conversation.dart';
import 'package:e_commerce/models/service/service_model.dart';
import 'package:e_commerce/providers/authentication/authentication_provider.dart';
import 'package:e_commerce/providers/chatting/chatting_provider.dart';
import 'package:e_commerce/providers/service/service_provider.dart';
import 'package:e_commerce/screens/chatting/chat_screen.dart';
import 'package:e_commerce/screens/orders/book_order_screen.dart';
import 'package:e_commerce/screens/reviews/service_review_detail_screen.dart';
import 'package:e_commerce/screens/service/update_service_screen.dart';
import 'package:e_commerce/screens/reviews/service_review_widget.dart';
import 'package:e_commerce/utils/app_theme.dart';
import 'package:e_commerce/utils/date_and_time_formatting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../common/snakbar/custom_snakbar.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false)
          .fetchSingleServiceDetail(widget.service.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, ServiceProvider>(
        builder: (context, authProvider, serviceProvider, child) {
      Future<void> handleConversation(
          BuildContext context,
          ChattingProvider chatProvider,
          String hostId,
          String currentUserId) async {
        // First, check if a conversation already exists with the host
        Conversation? existingConversation;

        try {
          existingConversation = chatProvider.conversations.firstWhere(
            (conversation) =>
                conversation.members.contains(currentUserId) &&
                conversation.members.contains(hostId),
          );
        } catch (e) {
          if (e is StateError) {
            existingConversation = null;
          } else {
            rethrow; // Unexpected error, rethrow it
          }
        }

        if (existingConversation != null) {
          // Navigate to the existing conversation
          Navigator.of(context).push(
            SlidePageRoute(
              page: ChatScreen(conversation: existingConversation),
            ),
          );
        } else {
          // No existing conversation, so create a new one
          int statusCode = await chatProvider.startConversation(
              hostId, authProvider.user!.id!);

          if (statusCode == 200) {
            // Fetch updated conversations
            await chatProvider.fetchConversations();

            try {
              // Check again for the newly created conversation
              existingConversation = chatProvider.conversations.firstWhere(
                (conversation) =>
                    conversation.members.contains(currentUserId) &&
                    conversation.members.contains(hostId),
              );

              // Navigate to the newly created conversation
              Navigator.of(context).push(
                SlidePageRoute(
                  page: ChatScreen(conversation: existingConversation),
                ),
              );
            } catch (e) {
              if (e is StateError) {
                showCustomSnackBar(
                    context,
                    "Conversation created, but couldn't be found in the list.",
                    Colors.red);
              } else {
                rethrow; // Unexpected error, rethrow it
              }
            }
          } else {
            // Handle error if conversation creation failed
            showCustomSnackBar(context,
                chatProvider.errorMessage ?? "Error occurred", Colors.red);
          }
        }
      }

      final isServiceProvider =
          authProvider.user?.role?.title == "service_provider" &&
              authProvider.user?.id ==
                  serviceProvider.service?.data?.specificService?.userId;

      return Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              "Service Details",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, 
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.accentText,
              ),
            ),
            actions: isServiceProvider
                ? [
                    IconButton(
                      icon: const Icon(IconlyLight.edit),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdateServiceScreen(
                            serviceDetail: serviceProvider.service!,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(IconlyLight.delete),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Delete Service"),
                              content: const Text(
                                  "Are you sure you want to delete this service?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop(false), // Cancel
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop(true), // Confirm
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          // Call the provider method to delete the service
                          await Provider.of<ServiceProvider>(context,
                                  listen: false)
                              .deleteService(widget.service.id);

                          final provider = Provider.of<ServiceProvider>(context,
                              listen: false);
                          if (provider.errorMessage == null) {
                            // Show success message
                            showCustomSnackBar(context,
                                "Service deleted successfully!", Colors.green);
                            Navigator.pop(context); // Navigate back
                          } else {
                            // Show error message
                            showCustomSnackBar(
                                context, provider.errorMessage!, Colors.red);
                          }
                        }
                      },
                    ),
                  ]
                : null),
        body: Consumer<ServiceProvider>(
          builder: (context, serviceProvider, child) {
            if (serviceProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (serviceProvider.errorMessage?.isNotEmpty ?? false) {
              return Center(child: Text(serviceProvider.errorMessage!));
            }

            final service = serviceProvider.service?.data?.specificService;
            if (service == null) {
              return const Center(child: Text("No service details available."));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  service.coverPhoto != null
                      ? SizedBox(
                          height: 200, // Reduced height to show more content
                          width: double.infinity,
                          child: Image.network(
                            '${service.coverPhoto}',
                            fit: BoxFit.cover,
                          ),
                        )
                      : SizedBox(
                          height: 200, // Reduced height to match network image
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/content-writer.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            service.serviceName ?? "No Name",
                            style: GoogleFonts.inter(
                              fontSize: 20, 
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.accentText,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.amber.withOpacity(0.2) : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                IconlyBold.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                serviceProvider.service?.data?.averageRating?.toString() ?? "0.0",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      service.description ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.5,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Service Information",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.accentText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(IconlyLight.location, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Location",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      service.city ?? "Not specified",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(IconlyLight.time_circle, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Service Hours",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${getFormattedTime12Hour(service.startTime.toString())} - ${getFormattedTime12Hour(service.endTime.toString())}",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (service.isAvailable == true) ...[  
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(IconlyBold.tick_square, size: 20, color: AppTheme.success),
                                const SizedBox(width: 12),
                                Text(
                                  "Available for Booking",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ],
                            ),
                          ] else if (service.isAvailable == false) ...[  
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(IconlyBold.close_square, size: 20, color: AppTheme.error),
                                const SizedBox(width: 12),
                                Text(
                                  "Currently Unavailable",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Divider(),

                  // Reviews Section
                  // Reviews title removed

                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: serviceProvider
                            .service!.data!.specificService!.reviews!.isNotEmpty
                        ? SizedBox(
                            height: 150, // Adjust height to fit your UI needs
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: serviceProvider.service!.data!
                                  .specificService!.reviews!.length,
                              itemBuilder: (ctx, index) {
                                final reversedReviews = serviceProvider.service!
                                    .data!.specificService!.reviews!.reversed
                                    .toList();
                                final review = reversedReviews[index];

                                // final review = serviceProvider.service!.data!
                                //     .specificService!.reviews![index];
                                // Only display reviews that are not empty
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlidePageRoute(
                                        page:
                                            ReviewDetailsScreen(review: review),
                                      ),
                                    );
                                  },
                                  child: ReviewWidget(review: review),
                                ); // Custom widget for displaying review
                              },
                            ),
                          )
                        : const Text(
                            'No reviews available for this yet.',
                            style: TextStyle(fontSize: 14),
                          ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Service Provider",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(service.user?.profilePicture),
                          radius: 20,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${service.user?.firstName ?? "Unknown"} ${service.user?.lastName ?? ""}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              service.user?.address?.location ?? "",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Consumer<ServiceProvider>(
          builder: (context, serviceProvider, child) {
            final isServiceByMe = authProvider.user?.id ==
                serviceProvider.service?.data?.specificService?.userId;
            Brightness brightness = Theme.of(context).brightness;
            bool isDarkMode = brightness == Brightness.dark;
            final price = serviceProvider.service?.data?.specificService?.price;
            return CardyContainer(
              color: isDarkMode ? AppTheme.darkSurface : Colors.white,
              spreadRadius: 0,
              blurRadius: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              height: 100,
              borderRadius: BorderRadius.circular(AppTheme.radius_lg),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: isServiceByMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Price label removed
                      Text(
                        "Rs${price ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppTheme.accentText,
                        ),
                      ),
                    ],
                  ),
                  if (!isServiceByMe) ...[
                    Row(
                      children: [
                        Consumer<ChattingProvider>(
                            builder: (context, chatProvider, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.all(12),
                              minimumSize: const Size(54, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radius_circle),
                              ),
                            ),
                            onPressed: () async {
                              await handleConversation(
                                context,
                                chatProvider,
                                serviceProvider
                                    .service!.data!.specificService!.userId!,
                                authProvider.user!.id!,
                              );
                            },
                            child: const Icon(
                              IconlyLight.chat,
                              color: Colors.white,
                            ),
                          );
                        }),
                        
                        const SizedBox(
                          width: 4,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                            minimumSize: const Size(150, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radius_md),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                page: BookOrderScreen(
                                  service: serviceProvider
                                      .service?.data?.specificService,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Book Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
