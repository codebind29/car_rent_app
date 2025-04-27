class Car2 {
  final String carName;
  final String fuelType;
  final String transmission;
  final String availabilityDate;
  final String price;
  final String oldPrice;

  Car2({

    required this.carName,
    required this.fuelType,
    required this.transmission,
    required this.availabilityDate,
    required this.price,
    required this.oldPrice,
  });

  factory Car2.fromJson(Map<String, dynamic> json) {
    return Car2(
      carName: json['carName'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      availabilityDate: json['availabilityDate'],
      price: json['price'],
      oldPrice: json['oldPrice'],
    );
  }
}




