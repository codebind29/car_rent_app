import 'package:car_rent/data/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCarDataSource {
  final FirebaseFirestore firestore;

  FirebaseCarDataSource({required this.firestore});

  Future<List<Car>> getCars() async {
    var snapshot = await firestore.collection('cars').get();

    return snapshot.docs.map((doc) =>
        Car.fromMap(doc.data() as String, doc.id as Map<String, dynamic>) // Corrected argument types
    ).toList();
  }
}

