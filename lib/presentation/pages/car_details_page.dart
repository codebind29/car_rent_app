import 'package:car_rent/presentation/pages/booking_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../data/models/car.dart';
import 'MapsDetailsPage.dart';

class CardDetailsPage extends StatefulWidget {
  final String carId;
  final Car car;

  const CardDetailsPage({super.key, required this.carId, required this.car});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  bool _isFavorite = false;
  int _selectedTab = 0;
  double _userRating = 0;
  Car? _car;
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    try {
      final doc = await _firestore.collection('cars').doc(widget.carId).get();
      if (doc.exists) {
        print('Firestore data: ${doc.data()}'); // Debug print
        setState(() {
          _car = Car.fromMap(doc.id, doc.data()!);
          print('Loaded car features: ${_car!.features}'); // Debug print
          _isLoading = false;
        });

        final user = _auth.currentUser;
        if (user != null) {
          final favDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .doc(widget.carId)
              .get();
          setState(() {
            _isFavorite = favDoc.exists;
          });
        }
      }
    } catch (e) {
      print('Error loading car: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add favorites')),
      );
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.carId)
            .set({
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.carId)
            .delete();
      }
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorites')),
      );
    }
  }

  Future<void> _submitReview() async {
    final user = _auth.currentUser;
    if (user == null || _userRating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in and provide a rating and review')),
      );
      return;
    }

    try {
      final review = {
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userImageUrl': '',
        'rating': _userRating,
        'comment': _reviewController.text,
        'date': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('cars').doc(widget.carId).update({
        'reviews': FieldValue.arrayUnion([review]),
      });

      final carDoc = await _firestore.collection('cars').doc(widget.carId).get();
      final reviews = (carDoc.data()!['reviews'] as List<dynamic>);
      final avgRating = reviews
          .map((r) => (r['rating'] as num).toDouble())
          .reduce((a, b) => a + b) / reviews.length;

      await _firestore.collection('cars').doc(widget.carId).update({
        'rating': avgRating,
      });

      setState(() {
        _reviewController.clear();
        _userRating = 0;
        _loadCarData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );
    }

    if (_car == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 16),
              const Text(
                'Car not found',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    // Debug prints to verify features
    print('Current car features: ${_car!.features}');
    print('Features type: ${_car!.features.runtimeType}');
    if (_car!.features.isNotEmpty) {
      print('First feature: ${_car!.features[0]}');
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _getCarColor(_car!.type),
                child: Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 120,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              title: Text(
                _car!.model,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(1, 1),
                    )
                  ],
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildTabButton(0, 'Details'),
                      _buildTabButton(1, 'Features'),
                      _buildTabButton(2, 'Reviews'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade50, Colors.blue.shade100],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.blue.shade200,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _car!.ownerName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              Text(
                                'Owner',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RatingBarIndicator(
                                rating: _car!.ownerRating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapsDetailsPage(car: _car!),
                              ),
                            );
                          },
                          child: Container(
                            height: 170,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: Colors.blue.shade800,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _car!.city,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to view location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapsDetailsPage(car: _car!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('View Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '₹${_car!.pricePerHour}/hour',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(
                      car: _car!,
                      loggedInUserName: _auth.currentUser?.displayName ?? '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCarColor(String type) {
    switch (type.toLowerCase()) {
      case 'suv':
        return Colors.blue.shade300;
      case 'sedan':
        return Colors.green.shade300;
      case 'hatchback':
        return Colors.orange.shade300;
      case 'luxury':
        return Colors.purple.shade300;
      default:
        return Colors.blue.shade600;
    }
  }

  Widget _buildTabButton(int index, String text) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
                color: _selectedTab == index ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // Details
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(Icons.speed, 'Mileage', '${_car!.distance} km'),
            _buildDetailItem(Icons.local_gas_station, 'Fuel', '${_car!.fuelCapacity} L (${_car!.fuelType})'),
            _buildDetailItem(Icons.airline_seat_recline_normal, 'Seats', '${_car!.seats}'),
            _buildDetailItem(Icons.directions_car, 'Type', _car!.type),
            _buildDetailItem(Icons.color_lens, 'Color', _car!.color),
            _buildDetailItem(Icons.star, 'Rating', '${_car!.rating}'),
          ],
        );
      case 1: // Features
        if (_car!.features.isEmpty) {
          return const Center(
            child: Text(
              'No features listed for this vehicle',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _car!.features.map((feature) {
            return Chip(
              label: Text(feature),
              backgroundColor: Colors.blue.shade50,
              labelStyle: TextStyle(color: Colors.blue.shade800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        );
      case 2: // Reviews
        return Column(
          children: [
            RatingBar.builder(
              initialRating: _userRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _userRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Write your review...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitReview,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (_car!.reviews.isEmpty)
              const Center(
                child: Text(
                  'No reviews yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ..._car!.reviews.map((review) => _buildReview(
              review.userName,
              review.comment,
              review.rating.toInt(),
            )),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(String name, String review, int rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade200,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < rating ? Colors.amber : Colors.grey,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review),
          ],
        ),
      ),
    );
  }
}
