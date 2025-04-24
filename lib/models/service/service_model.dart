import 'package:e_commerce/utils/api_constnsts.dart';

class ServiceModel {
  final String id;
  final String serviceName;
  final String description;
  final String? userId;
  final String? categoryId;
  final dynamic price;
  final bool? isAvailable;
  final String? city;
  final String? coverPhoto;
  final String? startTime;
  final String? endTime;
  final User? user;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.description,
    this.userId,
    this.categoryId,
    this.price,
    this.isAvailable,
    this.city,
    this.coverPhoto,
    this.startTime,
    this.endTime,
    this.user,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      serviceName: json['service_name'] ?? '',
      description: json['description'] ?? '',
      userId: json['user_id'],
      categoryId: json['category_id'],
      price: json['price']?.toString(),
      isAvailable: json['is_available'],
      city: json['city'],
      coverPhoto: json["cover_photo"]/* != null
          ? "${Constants.baseUrl}/${json["cover_photo"]}"
          : null*/,
      startTime: json['start_time'],
      endTime: json['end_time'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  factory ServiceModel.fromJsonGetMyServices(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      serviceName: json['service_name'] ?? '',
      description: json['description'] ?? '',
      userId: json['user_id'],
      categoryId: json['category_id'],
      price: json['price']?.toString(),
      isAvailable: json['is_available'],
      city: json['city'],
      coverPhoto: json["cover_photo"] /*!= null
          ? "${Constants.baseUrl}/${json["cover_photo"]}"
          : null*/,
      startTime: json['start_time'],
      endTime: json['end_time'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  // Add the copyWith method
  ServiceModel copyWith({
    String? id,
    String? serviceName,
    String? description,
    dynamic price,
    bool? isAvailable,
    String? city,
    String? coverPhoto,
    String? startTime,
    String? endTime,
    User? user,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      city: city ?? this.city,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      user: user ?? this.user,
    );
  }
}

class User {
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  User({
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
    );
  }
}
