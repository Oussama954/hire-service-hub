import 'dart:convert';

import 'package:e_commerce/utils/api_constnsts.dart';

class GetMyOrders {
  final bool success;
  final int statusCode;
  final String message;
  final List<Datum> data;

  GetMyOrders({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory GetMyOrders.fromRawJson(String str) =>
      GetMyOrders.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetMyOrders.fromJson(Map<String, dynamic> json) => GetMyOrders(
        success: json["success"] ?? false,
        statusCode: json["statusCode"] ?? 200,
        message: json["message"] ?? "Success",
        data: json["data"] != null
            ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data.map((x) => x.toJson()).toList(),
      };
}

class Datum {
  final String id;
  final String customerId;
  final String serviceId;
  final String serviceProviderId;
  final DateTime placedAt;
  final DateTime orderDate;
  final String orderStatus;
  final String? orderPrice;
  final String paymentStatus;
  final String paymentMethod;
  final Address customerAddress;
  final String? additionalNotes;
  final DateTime? orderCompletionDate;
  final String? cancellationReason;
  final Service service;
  final Customer? customer;
  final Customer? serviceProvider;

  Datum({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.serviceProviderId,
    required this.placedAt,
    required this.orderDate,
    required this.orderStatus,
    this.orderPrice,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.customerAddress,
    this.additionalNotes,
    this.orderCompletionDate,
    this.cancellationReason,
    required this.service,
    this.customer,
    this.serviceProvider,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    try {
      // Add logging to see exact structure
      print('Parsing booking: ${json["id"]}');
      
      // Special handling for service data which has a different structure
      Map<String, dynamic>? serviceData = json["service"] as Map<String, dynamic>?;
      if (serviceData != null) {
        // Check if service data has the provider field
        var providerData = serviceData["provider"] as Map<String, dynamic>?;
        if (providerData != null) {
          print('Service includes provider data: ${providerData["id"]}');
        }
      }
      
      // Process customer and provider data carefully
      Map<String, dynamic>? customerData = json["customer"] as Map<String, dynamic>?;
      
      // Try multiple possible field names for service provider
      Map<String, dynamic>? providerData = 
          json["service_provider"] as Map<String, dynamic>? ?? 
          json["serviceProvider"] as Map<String, dynamic>? ??
          (serviceData != null ? serviceData["provider"] as Map<String, dynamic>? : null);
      
      Map<String, dynamic>? addressData = json["customer_address"] as Map<String, dynamic>?;
      
      // Create a simplified Customer object if we only have basic provider info
      Customer? serviceProvider = null;
      if (providerData != null) {
        try {
          // Get avatar URL - if it's from the provider field in service object, it might be directly in 'avatar'
          String? avatarUrl = providerData["avatar"]?.toString() ?? 
                             providerData["profile_picture"]?.toString();
          
          // If avatar is null or empty, use the default avatar
          if (avatarUrl == null || avatarUrl.isEmpty) {
            avatarUrl = 'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg';
          }
          
          serviceProvider = Customer(
            id: providerData["id"]?.toString() ?? '',
            email: providerData["email"]?.toString() ?? '',
            firstName: providerData["first_name"]?.toString() ?? providerData["name"]?.toString() ?? '',
            lastName: providerData["last_name"]?.toString() ?? '',
            phone: providerData["phone"]?.toString() ?? '',
            gender: providerData["gender"]?.toString() ?? '',
            profilePicture: avatarUrl,
            cnic: providerData["cnic"]?.toString() ?? '',
            roleId: providerData["role_id"]?.toString() ?? '',
            isVerified: providerData["is_verified"] ?? false,
            isAdmin: providerData["is_admin"] ?? false,
            address: Address.defaultAddress(),
            bio: providerData["bio"]?.toString() ?? '',
            isComplete: providerData["is_complete"] ?? false,
          );
        } catch (e) {
          print('Error parsing provider data: $e');
          serviceProvider = null;
        }
      }
      
      // Create a simplified Customer object for customer too
      Customer? customer = null;
      if (customerData != null) {
        try {
          customer = Customer(
            id: customerData["id"]?.toString() ?? '',
            email: customerData["email"]?.toString() ?? '',
            firstName: customerData["first_name"]?.toString() ?? customerData["name"]?.toString() ?? '',
            lastName: customerData["last_name"]?.toString() ?? '',
            phone: customerData["phone"]?.toString() ?? '',
            gender: customerData["gender"]?.toString() ?? '',
            profilePicture: customerData["avatar"]?.toString() ?? customerData["profile_picture"]?.toString(),
            cnic: customerData["cnic"]?.toString() ?? '',
            roleId: customerData["role_id"]?.toString() ?? '',
            isVerified: customerData["is_verified"] ?? false,
            isAdmin: customerData["is_admin"] ?? false,
            address: Address.defaultAddress(),
            bio: customerData["bio"]?.toString() ?? '',
            isComplete: customerData["is_complete"] ?? false,
          );
        } catch (e) {
          print('Error parsing customer data: $e');
          customer = null;
        }
      }
      
      // Now create a Service object with extra safety
      Service? service = null;
      if (serviceData != null) {
        try {
          String serviceName = serviceData["service_name"]?.toString() ?? 
                               serviceData["title"]?.toString() ?? '';
          
          service = Service(
            id: serviceData["id"]?.toString() ?? '',
            serviceName: serviceName,
            description: serviceData["description"]?.toString() ?? '',
            userId: serviceData["user_id"]?.toString() ?? serviceData["userId"]?.toString() ?? '',
            categoryId: serviceData["category_id"]?.toString() ?? serviceData["categoryId"]?.toString() ?? '',
            price: serviceData["price"] != null ? 
                double.tryParse(serviceData["price"].toString()) ?? 0.0 : 
                0.0,
            isAvailable: serviceData["is_available"] ?? serviceData["isAvailable"] ?? true,
            coverPhoto: serviceData["cover_photo"]?.toString() ?? serviceData["coverPhoto"]?.toString() ?? '',
            startTime: serviceData["start_time"] != null ? 
                DateTime.tryParse(serviceData["start_time"].toString()) ?? DateTime.now() : 
                DateTime.now(),
            endTime: serviceData["end_time"] != null ? 
                DateTime.tryParse(serviceData["end_time"].toString()) ?? DateTime.now() : 
                DateTime.now(),
            city: serviceData["city"]?.toString() ?? '',
          );
        } catch (e) {
          print('Error parsing service data: $e');
          service = Service.defaultService();
        }
      } else {
        service = Service.defaultService();
      }
      
      return Datum(
        id: json["id"]?.toString() ?? '',
        customerId: json["customer_id"]?.toString() ?? '',
        serviceId: json["service_id"]?.toString() ?? '',
        serviceProviderId: json["service_provider_id"]?.toString() ?? json["provider_id"]?.toString() ?? '',
        placedAt: json["placed_at"] != null ? 
            DateTime.tryParse(json["placed_at"].toString()) ?? DateTime.now() : 
            DateTime.now(),
        orderDate: json["order_date"] != null ? 
            DateTime.tryParse(json["order_date"].toString()) ?? DateTime.now() : 
            DateTime.now(),
        orderStatus: json["order_status"]?.toString() ?? json["status"]?.toString() ?? 'pending',
        orderPrice: json["order_price"]?.toString() ?? json["amount"]?.toString() ?? "0",
        paymentStatus: json["payment_status"]?.toString() ?? 'pending',
        paymentMethod: json["payment_method"]?.toString() ?? 'cod',
        customerAddress: addressData != null ? 
            Address.fromJson(addressData) : 
            Address.defaultAddress(),
        additionalNotes: json["additional_notes"]?.toString() ?? json["special_instructions"]?.toString() ?? '',
        orderCompletionDate: json["order_completion_date"] != null ?
            DateTime.tryParse(json["order_completion_date"].toString()) :
            null,
        cancellationReason: json["cancellation_reason"]?.toString(),
        service: service,
        customer: customer,
        serviceProvider: serviceProvider,
      );
    } catch (e) {
      print('Error parsing booking: $e');
      print('Problematic JSON: $json');
      
      // Return a placeholder booking in case of error
      return Datum.defaultDatum();
    }
  }

  factory Datum.defaultDatum() {
    return Datum(
      id: 'error',
      customerId: '',
      serviceId: '',
      serviceProviderId: '',
      placedAt: DateTime.now(),
      orderDate: DateTime.now(),
      orderStatus: 'error',
      orderPrice: '0',
      paymentStatus: 'error',
      paymentMethod: 'error',
      customerAddress: Address.defaultAddress(),
      service: Service.defaultService(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "service_id": serviceId,
        "service_provider_id": serviceProviderId,
        "placed_at": placedAt.toIso8601String(),
        "order_date": orderDate.toIso8601String(),
        "order_status": orderStatus,
        "order_price": orderPrice,
        "payment_status": paymentStatus,
        "payment_method": paymentMethod,
        "customer_address": customerAddress.toJson(),
        "additional_notes": additionalNotes,
        "order_completion_date": orderCompletionDate?.toIso8601String(),
        "cancellation_reason": cancellationReason,
        "service": service.toJson(),
        "customer": customer?.toJson(),
        "service_provider": serviceProvider?.toJson(),
      };
}

class Customer {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? gender;
  final String? profilePicture;
  final String cnic;
  final String roleId;
  final bool isVerified;
  final bool isAdmin;
  final Address address;
  final String bio;
  final bool isComplete;

  Customer({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    this.profilePicture,
    required this.cnic,
    required this.roleId,
    required this.isVerified,
    required this.isAdmin,
    required this.address,
    required this.bio,
    required this.isComplete,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    try {
      return Customer(
        id: json["id"]?.toString() ?? '',
        email: json["email"]?.toString() ?? '',
        firstName: json["first_name"]?.toString() ?? json["name"]?.toString() ?? '',
        lastName: json["last_name"]?.toString() ?? '',
        phone: json["phone"]?.toString() ?? '',
        gender: json["gender"]?.toString() ?? '',
        profilePicture: json['profile_picture'] != null
            ? json['profile_picture'].toString()
            : 'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg',
        cnic: json["cnic"]?.toString() ?? '',
        roleId: json["role_id"]?.toString() ?? '',
        isVerified: json["is_verified"] ?? false,
        isAdmin: json["is_admin"] ?? false,
        address: json["address"] != null ? Address.fromJson(json["address"]) : Address.defaultAddress(),
        bio: json["bio"]?.toString() ?? '',
        isComplete: json["is_complete"] ?? false,
      );
    } catch (e) {
      print('Error parsing customer: $e');
      print('Problematic JSON: $json');
      return Customer(
        id: '',
        email: '',
        firstName: '',
        lastName: '',
        phone: '',
        gender: '',
        profilePicture: null,
        cnic: '',
        roleId: '',
        isVerified: false,
        isAdmin: false,
        address: Address.defaultAddress(),
        bio: '',
        isComplete: false,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "gender": gender,
        "profile_picture": profilePicture,
        "cnic": cnic,
        "role_id": roleId,
        "is_verified": isVerified,
        "is_admin": isAdmin,
        "address": address.toJson(),
        "bio": bio,
        "is_complete": isComplete,
      };
}

class Address {
  final int streetNo;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? location;

  Address({
    required this.streetNo,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.location,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    try {
      return Address(
        streetNo: json["street_no"] is int ? 
            json["street_no"] : 
            int.tryParse(json["street_no"]?.toString() ?? "0") ?? 0,
        city: json["city"]?.toString() ?? '',
        state: json["state"]?.toString() ?? '',
        postalCode: json["postal_code"]?.toString() ?? '',
        country: json["country"]?.toString() ?? '',
        location: json["location"]?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing address: $e');
      print('Problematic JSON: $json');
      return Address.defaultAddress();
    }
  }

  factory Address.defaultAddress() {
    return Address(
      streetNo: 0,
      city: '',
      state: '',
      postalCode: '',
      country: '',
      location: '',
    );
  }

  Map<String, dynamic> toJson() => {
        "street_no": streetNo,
        "city": city,
        "state": state,
        "postal_code": postalCode,
        "country": country,
        "location": location,
      };
}

class Service {
  String id;
  String serviceName;
  String description;
  String userId;
  String categoryId;
  double price;
  bool isAvailable;
  dynamic coverPhoto;
  DateTime startTime;
  DateTime endTime;
  String city;

  Service({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.userId,
    required this.categoryId,
    required this.price,
    required this.isAvailable,
    required this.coverPhoto,
    required this.startTime,
    required this.endTime,
    required this.city,
  });

  factory Service.fromRawJson(String str) => Service.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      // Since the backend is sending 'title' instead of 'service_name'
      String serviceName = json["service_name"]?.toString() ?? json["title"]?.toString() ?? '';
      
      return Service(
        id: json["id"]?.toString() ?? '',
        serviceName: serviceName,
        description: json["description"]?.toString() ?? '',
        userId: json["user_id"]?.toString() ?? json["userId"]?.toString() ?? '',
        categoryId: json["category_id"]?.toString() ?? json["categoryId"]?.toString() ?? '',
        price: json["price"] != null ? 
            double.tryParse(json["price"].toString()) ?? 0.0 : 
            0.0,
        isAvailable: json["is_available"] ?? json["isAvailable"] ?? true,
        coverPhoto: json["cover_photo"]?.toString() ?? json["coverPhoto"]?.toString() ?? '',
        startTime: json["start_time"] != null ? 
            DateTime.tryParse(json["start_time"].toString()) ?? DateTime.now() : 
            DateTime.now(),
        endTime: json["end_time"] != null ? 
            DateTime.tryParse(json["end_time"].toString()) ?? DateTime.now() : 
            DateTime.now(),
        city: json["city"]?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing service: $e');
      print('Problematic JSON: $json');
      return Service.defaultService();
    }
  }

  factory Service.defaultService() {
    return Service(
      id: '',
      serviceName: '',
      description: '',
      userId: '',
      categoryId: '',
      price: 0.0,
      isAvailable: false,
      coverPhoto: '',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      city: '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "service_name": serviceName,
        "description": description,
        "user_id": userId,
        "category_id": categoryId,
        "price": price,
        "is_available": isAvailable,
        "cover_photo": coverPhoto,
        "start_time": startTime.toIso8601String(),
        "end_time": endTime.toIso8601String(),
        "city": city,
      };
}
