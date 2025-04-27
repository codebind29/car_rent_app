import 'car2.dart';

class CarSubscription {
  final String id;
  final Car2 car;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyPrice;
  final double totalPrice;
  final double discount;
  final String status; // 'active', 'pending', 'cancelled', 'completed'
  final String paymentMethod;

  CarSubscription({
    required this.id,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.monthlyPrice,
    required this.totalPrice,
    required this.discount,
    required this.status,
    required this.paymentMethod,
  });

  factory CarSubscription.fromJson(Map<String, dynamic> json) {
    return CarSubscription(
      id: json['id'],
      car: Car2.fromJson(json['car']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      monthlyPrice: json['monthlyPrice'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      discount: json['discount'].toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'car': {
      'carName': car.carName,
      'fuelType': car.fuelType,
      'transmission': car.transmission,
      'availabilityDate': car.availabilityDate,
      'price': car.price,
      'oldPrice': car.oldPrice,
    },
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'monthlyPrice': monthlyPrice,
    'totalPrice': totalPrice,
    'discount': discount,
    'status': status,
    'paymentMethod': paymentMethod,
  };
}