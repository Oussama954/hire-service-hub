// To parse this JSON data, do
//
//     final fetchSingleService = fetchSingleServiceFromJson(jsonString);

import 'dart:convert';

import 'package:e_commerce/utils/api_constnsts.dart';

FetchSingleService fetchSingleServiceFromJson(String str) =>
    FetchSingleService.fromJson(json.decode(str));

String fetchSingleServiceToJson(FetchSingleService data) =>
    json.encode(data.toJson());

class FetchSingleService {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  FetchSingleService({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  FetchSingleService copyWith({
    bool? success,
    int? statusCode,
    String? message,
    Data? data,
  }) =>
      FetchSingleService(
        success: success ?? this.success,
        statusCode: statusCode ?? this.statusCode,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory FetchSingleService.fromJson(Map<String, dynamic> json) =>
      FetchSingleService(
        success: json["success"],
        statusCode: json["statusCode"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  SpecificService? specificService;
  int? averageRating;

  Data({
    this.specificService,
    this.averageRating,
  });

  Data copyWith({
    SpecificService? specificService,
    int? averageRating,
  }) =>
      Data(
        specificService: specificService ?? this.specificService,
        averageRating: averageRating ?? this.averageRating,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        specificService: json["specificService"] == null
            ? null
            : SpecificService.fromJson(json["specificService"]),
        averageRating: json["averageRating"],
      );

  Map<String, dynamic> toJson() => {
        "specificService": specificService?.toJson(),
        "averageRating": averageRating,
      };
}

class SpecificService {
  String? id;
  String? serviceName;
  String? description;
  String? userId;
  String? categoryId;
  String? price;
  bool? isAvailable;
  dynamic coverPhoto;
  DateTime? startTime;
  DateTime? endTime;
  String? city;
  User? user;
  Category? category;
  List<Review>? reviews;

  SpecificService({
    this.id,
    this.serviceName,
    this.description,
    this.userId,
    this.categoryId,
    this.price,
    this.isAvailable,
    this.coverPhoto,
    this.startTime,
    this.endTime,
    this.city,
    this.user,
    this.category,
    this.reviews,
  });

  SpecificService copyWith({
    String? id,
    String? serviceName,
    String? description,
    String? userId,
    String? categoryId,
    String? price,
    bool? isAvailable,
    dynamic coverPhoto,
    DateTime? startTime,
    DateTime? endTime,
    String? city,
    User? user,
    Category? category,
    List<Review>? reviews,
  }) =>
      SpecificService(
        id: id ?? this.id,
        serviceName: serviceName ?? this.serviceName,
        description: description ?? this.description,
        userId: userId ?? this.userId,
        categoryId: categoryId ?? this.categoryId,
        price: price ?? this.price,
        isAvailable: isAvailable ?? this.isAvailable,
        coverPhoto: coverPhoto ?? this.coverPhoto,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        city: city ?? this.city,
        user: user ?? this.user,
        category: category ?? this.category,
        reviews: reviews ?? this.reviews,
      );

  factory SpecificService.fromJson(Map<String, dynamic> json) =>
      SpecificService(
        id: json["id"]?.toString() ?? "",
        serviceName: json["serviceName"] ?? json["service_name"] ?? "",
        description: json["description"] ?? "",
        userId: json["userId"]?.toString() ?? json["user_id"]?.toString() ?? "",
        categoryId: json["categoryId"]?.toString() ?? json["category_id"]?.toString() ?? "",
        price: json["price"]?.toString() ?? "0",
        isAvailable: json["isAvailable"] ?? true,
        coverPhoto: json["coverPhoto"] ?? '',
        startTime: json["startTime"] is String && json["startTime"] != null && json["startTime"].isNotEmpty
            ? DateTime.tryParse(json["startTime"])
            : null,
        endTime: json["endTime"] is String && json["endTime"] != null && json["endTime"].isNotEmpty
            ? DateTime.tryParse(json["endTime"])
            : null,
        city: json["city"] ?? "",
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
        reviews: json["reviews"] == null
            ? []
            : List<Review>.from(
                (json["reviews"] as List).map((x) => Review.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service_name": serviceName,
        "description": description,
        "user_id": userId,
        "category_id": categoryId,
        "price": price,
        "is_available": isAvailable,
        "cover_photo": coverPhoto,
        "start_time": startTime?.toIso8601String(),
        "end_time": endTime?.toIso8601String(),
        "city": city,
        "user": user?.toJson(),
        "category": category?.toJson(),
        "reviews":
            reviews == null ? [] : List<Review>.from(reviews!.map((x) => x)),
      };
}

class Review {
  String id;
  String reviewerId;
  String serviceId;
  String reviewMessage;
  int rating;
  DateTime addedAt;
  Reviewer reviewer;

  Review({
    required this.id,
    required this.reviewerId,
    required this.serviceId,
    required this.reviewMessage,
    required this.rating,
    required this.addedAt,
    required this.reviewer,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"]?.toString() ?? '',
        reviewerId: json["reviewer_id"]?.toString() ?? '',
        serviceId: json["service_id"]?.toString() ?? '',
        reviewMessage: json["review_message"] ?? json["comment"] ?? '',
        rating: json["rating"] is int ? json["rating"] : int.tryParse(json["rating"].toString()) ?? 0,
        addedAt: json["added_at"] != null && json["added_at"].toString().isNotEmpty
            ? DateTime.tryParse(json["added_at"].toString()) ?? DateTime(1970)
            : DateTime(1970),
        reviewer: json["reviewer"] != null ? Reviewer.fromJson(json["reviewer"]) : Reviewer(firstName: '', lastName: '', email: '', profilePicture: ''),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reviewer_id": reviewerId,
        "service_id": serviceId,
        "review_message": reviewMessage,
        "rating": rating,
        "added_at": addedAt.toIso8601String(),
        "reviewer": reviewer.toJson(),
      };
}

class Reviewer {
  String firstName;
  String lastName;
  String email;
  String profilePicture;

  Reviewer({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePicture,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        profilePicture: json['profile_picture'] != null
            ? json['profile_picture']
            : 'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg',
      );

  Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "profile_picture": profilePicture,
      };
}

class Category {
  String? id;
  String? title;
  String? description;
  bool? isAvailable;

  Category({
    this.id,
    this.title,
    this.description,
    this.isAvailable,
  });

  Category copyWith({
    String? id,
    String? title,
    String? description,
    bool? isAvailable,
  }) =>
      Category(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isAvailable: isAvailable ?? this.isAvailable,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        isAvailable: json["is_available"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "is_available": isAvailable,
      };
}

class User {
  String? id;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? phone;
  String? gender;
  dynamic profilePicture;
  dynamic otp;
  String? cnic;
  String? roleId;
  bool? isVerified;
  bool? isAdmin;
  Address? address;
  String? bio;
  bool? isComplete;

  User({
    this.id,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.phone,
    this.gender,
    this.profilePicture,
    this.otp,
    this.cnic,
    this.roleId,
    this.isVerified,
    this.isAdmin,
    this.address,
    this.bio,
    this.isComplete,
  });

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? phone,
    String? gender,
    dynamic profilePicture,
    dynamic otp,
    String? cnic,
    String? roleId,
    bool? isVerified,
    bool? isAdmin,
    Address? address,
    String? bio,
    bool? isComplete,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        password: password ?? this.password,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        gender: gender ?? this.gender,
        profilePicture: profilePicture ?? this.profilePicture,
        otp: otp ?? this.otp,
        cnic: cnic ?? this.cnic,
        roleId: roleId ?? this.roleId,
        isVerified: isVerified ?? this.isVerified,
        isAdmin: isAdmin ?? this.isAdmin,
        address: address ?? this.address,
        bio: bio ?? this.bio,
        isComplete: isComplete ?? this.isComplete,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        password: json["password"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        phone: json["phone"],
        gender: json["gender"],
        profilePicture: json['profile_picture'] != null
            ? "${Constants.baseUrl}${json['profile_picture']}"
            : 'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg',
        otp: json["otp"],
        cnic: json["cnic"],
        roleId: json["role_id"],
        isVerified: json["is_verified"],
        isAdmin: json["is_admin"],
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
        bio: json["bio"],
        isComplete: json["is_complete"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "gender": gender,
        "profile_picture": profilePicture,
        "otp": otp,
        "cnic": cnic,
        "role_id": roleId,
        "is_verified": isVerified,
        "is_admin": isAdmin,
        "address": address?.toJson(),
        "bio": bio,
        "is_complete": isComplete,
      };
}

class Address {
  int? streetNo;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? location;

  Address({
    this.streetNo,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.location,
  });

  Address copyWith({
    int? streetNo,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? location,
  }) =>
      Address(
        streetNo: streetNo ?? this.streetNo,
        city: city ?? this.city,
        state: state ?? this.state,
        postalCode: postalCode ?? this.postalCode,
        country: country ?? this.country,
        location: location ?? this.location,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        streetNo: json["street_no"],
        city: json["city"],
        state: json["state"],
        postalCode: json["postal_code"],
        country: json["country"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "street_no": streetNo,
        "city": city,
        "state": state,
        "postal_code": postalCode,
        "country": country,
        "location": location,
      };
}
