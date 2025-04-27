import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String model;
  final String imageUrl;
  final double pricePerHour;
  final double pricePerDay;
  final double distance;
  final String ownerName;
  final String ownerImageUrl;
  final double ownerRating;
  final List<String> features;
  final List<Review> reviews;
  final String city;
  final double latitude;
  final double longitude;
  final String fuelType;
  final double rating;
  final double acceleration;
  final int seats;
  final double safetyRating;
  final double fuelCapacity;
  final String type;
  final String color;
  final bool isAvailable;
  final String? currentBookingId;
  final double securityDeposit;

  Car({
    required this.id,
    required this.model,
    required this.imageUrl,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.distance,
    required this.ownerName,
    required this.ownerImageUrl,
    required this.ownerRating,
    required this.features,
    required this.reviews,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.fuelType,
    required this.rating,
    required this.acceleration,
    required this.seats,
    required this.safetyRating,
    required this.fuelCapacity,
    required this.type,
    required this.color,
    this.isAvailable = true,
    this.currentBookingId,
    required this.securityDeposit,
  });

  factory Car.fromMap(String id, Map<String, dynamic> map) {
    return Car(
      id: id,
      model: map['model'] ?? 'Unknown Model',
      imageUrl: map['imageUrl'] ?? '',
      pricePerHour: (map['pricePerHour'] ?? 0).toDouble(),
      pricePerDay: (map['pricePerDay'] ?? (map['pricePerHour'] ?? 0) * 24).toDouble(),
      distance: (map['distance'] ?? 0).toDouble(),
      ownerName: map['ownerName'] ?? 'Private Owner',
      ownerImageUrl: map['ownerImageUrl'] ?? '',
      ownerRating: (map['ownerRating'] ?? 0).toDouble(),
      features: List<String>.from(map['features'] ?? []),
      reviews: (map['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromMap(review))
          .toList(),
      city: map['city'] ?? 'Unknown City',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      fuelType: map['fuelType'] ?? 'Petrol',
      rating: (map['rating'] ?? 0).toDouble(),
      acceleration: (map['acceleration'] ?? 10).toDouble(),
      seats: (map['seats'] ?? 5).toInt(),
      safetyRating: (map['safetyRating'] ?? 4).toDouble(),
      fuelCapacity: (map['fuelCapacity'] ?? 0).toDouble(),
      type: map['type'] ?? 'Sedan',
      color: map['color'] ?? 'Black',
      isAvailable: map['isAvailable'] ?? true,
      currentBookingId: map['currentBookingId'],
      securityDeposit: (map['securityDeposit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'imageUrl': imageUrl,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'distance': distance,
      'ownerName': ownerName,
      'ownerImageUrl': ownerImageUrl,
      'ownerRating': ownerRating,
      'features': features,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'fuelType': fuelType,
      'rating': rating,
      'acceleration': acceleration,
      'seats': seats,
      'safetyRating': safetyRating,
      'fuelCapacity': fuelCapacity,
      'type': type,
      'color': color,
      'isAvailable': isAvailable,
      'currentBookingId': currentBookingId,
      'securityDeposit': securityDeposit,
    };
  }
}

class Review {
  final String userName;
  final String comment;
  final double rating;
  final String userImageUrl;
  final DateTime date;

  Review({
    required this.userName,
    required this.comment,
    required this.rating,
    required this.userImageUrl,
    required this.date,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userName: map['userName'] ?? 'Anonymous',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      userImageUrl: map['userImageUrl'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'userImageUrl': userImageUrl,
      'date': Timestamp.fromDate(date),
    };
  }
}