import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class Car {
  final String id;
  final String name;
  final String model;
  final String fuelType;
  final String transmission;
  final double dailyPrice;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final bool isSubAvailable;

  Car({
    required this.id,
    required this.name,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.dailyPrice,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.isSubAvailable,
  });

  factory Car.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Car(
      id: doc.id,
      name: data['name'] ?? '',
      model: data['model'] ?? '',
      fuelType: data['fuelType'] ?? '',
      transmission: data['transmission'] ?? '',
      dailyPrice: (data['dailyPrice'] ?? 0).toDouble(),
      monthlyPrice: (data['monthlyPrice'] ?? 0).toDouble(),
      yearlyPrice: (data['yearlyPrice'] ?? 0).toDouble(),
      features: List<String>.from(data['features'] ?? []),
      isSubAvailable: data['isSubAvailable'] ?? true,
    );
  }
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedDuration = 1;
  final Map<int, String> _durationOptions = {
    1: 'Monthly',
    3: 'Quarterly',
    12: 'Yearly'
  };
  List<String> _subscribedCarIds = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSubscribedCars();
  }

  Future<void> _loadSubscribedCars() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('user_subscriptions')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .get();

    setState(() {
      _subscribedCarIds = snapshot.docs.map((doc) => doc['carId'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDurationSelector(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('subscriptions')
                  .where('isSubAvailable', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cars = snapshot.data!.docs
                    .map((doc) => Car.fromFirestore(doc))
                    .where((car) => !_subscribedCarIds.contains(car.id))
                    .toList();

                if (cars.isEmpty) {
                  return const Center(
                    child: Text(
                      'No available subscriptions or you have subscribed to all cars',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildCarCard(cars[index]),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Subscription Plan:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          DropdownButton<int>(
            value: _selectedDuration,
            items: _durationOptions.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDuration = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    double price;
    String priceLabel;

    switch (_selectedDuration) {
      case 1:
        price = car.monthlyPrice;
        priceLabel = 'per month';
        break;
      case 3:
        price = car.monthlyPrice * 3 * 0.9;
        priceLabel = 'for 3 months';
        break;
      case 12:
        price = car.yearlyPrice;
        priceLabel = 'per year';
        break;
      default:
        price = car.monthlyPrice;
        priceLabel = 'per month';
    }

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCarDetails(car),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${car.name} ${car.model}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${car.fuelType} • ${car.transmission}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    priceLabel,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showSubscriptionOptions(car),
                  child: const Text('Subscribe Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCarDetails(Car car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${car.name} ${car.model}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${car.fuelType} • ${car.transmission}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const Divider(height: 32),
              const Text(
                'Subscription Plans',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPriceComparison(car),
              const Divider(height: 32),
              const Text(
                'Features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...car.features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _showSubscriptionOptions(car),
                  child: const Text('PROCEED TO SUBSCRIPTION'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceComparison(Car car) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
      },
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Savings', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Monthly')),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('₹${car.monthlyPrice.toStringAsFixed(2)}')),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('-')),
          ],
        ),
        TableRow(
          children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Quarterly (10% off)')),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('₹${(car.monthlyPrice * 3 * 0.9).toStringAsFixed(2)}')),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('₹${(car.monthlyPrice * 3 * 0.1).toStringAsFixed(2)}')),
          ],
        ),
        TableRow(
          children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Yearly')),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('₹${car.yearlyPrice.toStringAsFixed(2)}')),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('₹${(car.monthlyPrice * 12 - car.yearlyPrice).toStringAsFixed(2)}')),
          ],
        ),
      ],
    );
  }

  void _showSubscriptionOptions(Car car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Subscription',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSubscriptionOption(
                title: 'Monthly Plan',
                price: car.monthlyPrice,
                duration: '1 month',
                savings: 0,
                isSelected: _selectedDuration == 1,
                onTap: () => _selectDuration(1, car),
              ),
              _buildSubscriptionOption(
                title: 'Quarterly Plan (10% off)',
                price: car.monthlyPrice * 3 * 0.9,
                duration: '3 months',
                savings: car.monthlyPrice * 3 * 0.1,
                isSelected: _selectedDuration == 3,
                onTap: () => _selectDuration(3, car),
              ),
              _buildSubscriptionOption(
                title: 'Yearly Plan',
                price: car.yearlyPrice,
                duration: '12 months',
                savings: car.monthlyPrice * 12 - car.yearlyPrice,
                isSelected: _selectedDuration == 12,
                onTap: () => _selectDuration(12, car),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showUpiPaymentDialog(car);
                  },
                  child: const Text('PAY WITH UPI'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required double price,
    required String duration,
    required double savings,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.teal.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.teal : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.teal : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    duration,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (savings > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Save ₹${savings.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectDuration(int duration, Car car) {
    setState(() {
      _selectedDuration = duration;
    });
    Navigator.pop(context);
    _showSubscriptionOptions(car);
  }

  void _showUpiPaymentDialog(Car car) {
    double price = _getPriceForSelectedDuration(car);
    String duration = _getDurationLabel();
    final upiId = '9322979933@kotak811';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Center(
          child: Text(
            'UPI Payment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 40,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    Text(
                      'For $duration',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Send payment to:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse('upi://pay?pa=$upiId&pn=CarRental&am=$price&cu=INR');
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No UPI app found')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.teal.withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'UPI ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        upiId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'TAP TO PAY',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'After successful payment, click "Payment Done"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              _completeSubscription(car, 'UPI');
            },
            child: const Text(
              'Payment Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSubscription(Car car, String paymentMethod) async {
    setState(() => _isProcessing = true);

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to subscribe')),
      );
      setState(() => _isProcessing = false);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Completing your subscription...'),
          ],
        ),
      ),
    );

    try {
      double price = _getPriceForSelectedDuration(car);
      String duration = _getDurationLabel();

      DateTime startDate = DateTime.now();
      DateTime endDate = _calculateEndDate(startDate);

      // Create subscription data
      Map<String, dynamic> subscriptionData = {
        'userId': user.uid,
        'carId': car.id,
        'carName': '${car.name} ${car.model}',
        'price': price,
        'duration': duration,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': 'active',
        'paymentStatus': 'completed',
        'paymentMethod': paymentMethod,
        'createdAt': Timestamp.now(),
      };

      // Update car availability
      await _firestore.collection('subscriptions').doc(car.id).update({
        'isSubAvailable': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add subscription
      await _firestore.collection('user_subscriptions').add(subscriptionData);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      _showSuccessDialog(car, price, duration);

      // Reload subscribed cars
      await _loadSubscribedCars();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  DateTime _calculateEndDate(DateTime startDate) {
    switch (_selectedDuration) {
      case 1: return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case 3: return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case 12: return DateTime(startDate.year + 1, startDate.month, startDate.day);
      default: return DateTime(startDate.year, startDate.month + 1, startDate.day);
    }
  }

  void _showSuccessDialog(Car car, double price, String duration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${car.name} ${car.model}'),
            const SizedBox(height: 8),
            Text('Plan: $duration'),
            const SizedBox(height: 8),
            Text('Amount: ₹${price.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Your subscription is now active.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: const Text('Filter functionality would go here'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  double _getPriceForSelectedDuration(Car car) {
    switch (_selectedDuration) {
      case 1:
        return car.monthlyPrice;
      case 3:
        return car.monthlyPrice * 3 * 0.9;
      case 12:
        return car.yearlyPrice;
      default:
        return car.monthlyPrice;
    }
  }

  String _getDurationLabel() {
    switch (_selectedDuration) {
      case 1:
        return '1 month';
      case 3:
        return '3 months';
      case 12:
        return '1 year';
      default:
        return '1 month';
    }
  }
}