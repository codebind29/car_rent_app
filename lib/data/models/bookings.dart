// models/booking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String carId;
  final String carModel;
  final String userName;
  final String licenseNumber;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double securityDeposit;
  final String status;
  final String? userId;
  final Timestamp createdAt;

  Booking({
    required this.id,
    required this.carId,
    required this.carModel,
    required this.userName,
    required this.licenseNumber,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.securityDeposit,
    required this.status,
    this.userId,
    required this.createdAt,
  });

  // Convert Booking object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carModel': carModel,
      'userName': userName,
      'licenseNumber': licenseNumber,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'securityDeposit': securityDeposit,
      'status': status,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  // Create Booking object from Firestore document
  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      carId: map['carId'] ?? '',
      carModel: map['carModel'] ?? '',
      userName: map['userName'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      location: map['location'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      securityDeposit: (map['securityDeposit'] ?? 0).toDouble(),
      status: map['status'] ?? 'Confirmed',
      userId: map['userId'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
/*
class Booking {
  final String id;
  final String carId;
  final String carModel;
  final String userName;
  final String licenseNumber;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double securityDeposit;
  final String status;
  final String? userId;
  final Timestamp createdAt;

  Booking({
    required this.id,
    required this.carId,
    required this.carModel,
    required this.userName,
    required this.licenseNumber,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.securityDeposit,
    required this.status,
    this.userId,
    required this.createdAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carModel': carModel,
      'userName': userName,
      'licenseNumber': licenseNumber,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'securityDeposit': securityDeposit,
      'status': status,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}
*/