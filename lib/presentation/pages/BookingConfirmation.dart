import 'package:flutter/material.dart';
import 'package:car_rent/data/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentTabIndex = 0; // 0 for bookings, 1 for subscriptions

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please sign in to view bookings',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings & Subscriptions'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildContent(userId)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentTabIndex == 0 ? Colors.teal : Colors.grey[300],
                foregroundColor: _currentTabIndex == 0 ? Colors.white : Colors.black,
              ),
              onPressed: () => setState(() => _currentTabIndex = 0),
              child: const Text('Bookings'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentTabIndex == 1 ? Colors.teal : Colors.grey[300],
                foregroundColor: _currentTabIndex == 1 ? Colors.white : Colors.black,
              ),
              onPressed: () => setState(() => _currentTabIndex = 1),
              child: const Text('Subscriptions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String userId) {
    return _currentTabIndex == 0
        ? _buildBookingsList(userId)
        : _buildSubscriptionsList(userId);
  }

  Widget _buildBookingsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bookings found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data!.docs[index];
            return _buildBookingCard(context, booking);
          },
        );
      },
    );
  }

  Widget _buildSubscriptionsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('user_subscriptions')
          .where('userId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No subscriptions found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final subscription = snapshot.data!.docs[index];
            return _buildSubscriptionCard(context, subscription);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, QueryDocumentSnapshot booking) {
    final data = booking.data() as Map<String, dynamic>;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = (data['endDate'] as Timestamp).toDate();
    final status = data['status'] ?? 'confirmed';
    final location = data['location'] ?? 'Not specified';

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    data['carImage'] ?? '',
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.car_rental),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['carModel'] ?? 'Unknown Car',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text('Pickup: $location'),
                      Text(
                        'Status: ${status.toUpperCase()}',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Car ID: ${data['carId'] ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.teal),
                  onPressed: () => _showBookingDetailsDialog(context, booking),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (status == 'confirmed')
                  ElevatedButton(
                    onPressed: () => _cancelBooking(context, booking.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                    ),
                    child: const Text('Cancel Booking'),
                  ),
                ElevatedButton(
                  onPressed: () => _callRentalService(),
                  child: const Text('Call Rental'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, QueryDocumentSnapshot subscription) {
    final data = subscription.data() as Map<String, dynamic>;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = (data['endDate'] as Timestamp).toDate();
    final status = data['status'] ?? 'active';
    final carId = data['carId'] ?? 'N/A';
    final carName = data['carName'] ?? 'Unknown Car';

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.subscriptions, size: 40, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Status: ${status.toUpperCase()}',
                        style: TextStyle(
                          color: _getSubscriptionStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Car ID: $carId',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Payment: ${data['paymentMethod'] ?? 'N/A'} (${data['paymentStatus'] ?? 'N/A'})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.orange),
                  onPressed: () => _showSubscriptionDetailsDialog(context, subscription),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (status == 'active')
                  ElevatedButton(
                    onPressed: () => _cancelSubscription(context, subscription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                    ),
                    child: const Text('Cancel Subscription'),
                  ),
                ElevatedButton(
                  onPressed: () => _callRentalService(),
                  child: const Text('Call Support'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBookingDetailsDialog(BuildContext context, QueryDocumentSnapshot booking) async {
    final data = booking.data() as Map<String, dynamic>;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = (data['endDate'] as Timestamp).toDate();
    final status = data['status'] ?? 'confirmed';
    final totalPrice = data['totalPrice'] ?? 0;
    final licenseNumber = data['licenseNumber'] ?? 'Not provided';
    final location = data['location'] ?? 'Not provided';

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Car Model:', data['carModel'] ?? 'Unknown'),
                _buildDetailRow('Car ID:', data['carId'] ?? 'N/A'),
                _buildDetailRow('Start Date:', DateFormat('MMM dd, yyyy').format(startDate)),
                _buildDetailRow('End Date:', DateFormat('MMM dd, yyyy').format(endDate)),
                _buildDetailRow('Total Price:', '₹${totalPrice.toStringAsFixed(2)}'),
                _buildDetailRow('Status:', status.toUpperCase(),
                    color: _getStatusColor(status)),
                _buildDetailRow('License Number:', licenseNumber),
                _buildDetailRow('Pickup Location:', location),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSubscriptionDetailsDialog(BuildContext context, QueryDocumentSnapshot subscription) async {
    final data = subscription.data() as Map<String, dynamic>;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = (data['endDate'] as Timestamp).toDate();
    final status = data['status'] ?? 'active';
    final price = data['price'] ?? 0;
    final duration = data['duration'] ?? 'Not specified';
    final paymentMethod = data['paymentMethod'] ?? 'Not specified';
    final paymentStatus = data['paymentStatus'] ?? 'Not specified';

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Subscription Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Car Name:', data['carName'] ?? 'Unknown'),
                _buildDetailRow('Car ID:', data['carId'] ?? 'N/A'),
                _buildDetailRow('Start Date:', DateFormat('MMM dd, yyyy').format(startDate)),
                _buildDetailRow('End Date:', DateFormat('MMM dd, yyyy').format(endDate)),
                _buildDetailRow('Duration:', duration),
                _buildDetailRow('Price:', '₹${price.toStringAsFixed(2)}'),
                _buildDetailRow('Status:', status.toUpperCase(),
                    color: _getSubscriptionStatusColor(status)),
                _buildDetailRow('Payment Method:', paymentMethod),
                _buildDetailRow('Payment Status:', paymentStatus),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'on_the_way':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getSubscriptionStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Get booking details
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final carId = bookingData['carId'];
      final totalPrice = bookingData['totalPrice'] ?? 0;

      // 2. Update car availability
      await _firestore.collection('cars').doc(carId).update({
        'isAvailable': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Process refund (using userId since we don't have paymentId)
      // In a real app, you would call your payment service here
      // For demo purposes, we'll just log it
      print('Processing refund of ₹$totalPrice for booking $bookingId');

      // 4. Update booking status
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully!')),
      );

      // Refresh the UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking: ${e.toString()}')),
      );
    }
  }

  Future<void> _cancelSubscription(BuildContext context, QueryDocumentSnapshot subscription) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel this subscription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final subscriptionData = subscription.data() as Map<String, dynamic>;
      final carId = subscriptionData['carId'];
      final price = subscriptionData['price'] ?? 0;

      // 1. Update subscription status
      await _firestore.collection('user_subscriptions').doc(subscription.id).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update car availability in subscriptions collection
      await _firestore.collection('subscriptions').doc(carId).update({
        'isSubAvailable': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Process refund (using userId since we don't have paymentId)
      // In a real app, you would call your payment service here
      // For demo purposes, we'll just log it
      print('Processing refund of ₹$price for subscription ${subscription.id}');

      // Close loading dialog
      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _callRentalService() async {
    const phoneNumber = '+919322979933';
    final url = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }
}

class BookingConfirmation extends StatelessWidget {
  final String bookingId;
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final bool isAdminView;

  const BookingConfirmation({
    super.key,
    required this.bookingId,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    this.isAdminView = false, required double securityDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final days = endDate.difference(startDate).inDays;
    final hours = endDate.difference(startDate).inHours;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.teal, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Confirmed!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Text(
                          'ID: ${bookingId.substring(0, 8).toUpperCase()}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Vehicle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            car.imageUrl,
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.car_rental, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.model,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                car.type,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '₹${car.pricePerHour.toStringAsFixed(0)}/h',
                              style: TextStyle(
                                color: Colors.teal[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${car.pricePerDay.toStringAsFixed(0)}/d',
                              style: TextStyle(
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(Icons.people, '${car.seats} Seats'),
                        _buildFeatureItem(Icons.local_gas_station, car.fuelType),
                        _buildFeatureItem(Icons.speed, '${car.acceleration}s'),
                        _buildFeatureItem(Icons.star, car.rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Booking Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDateRow('Pickup Date', startDate),
                    const SizedBox(height: 16),
                    _buildDateRow('Return Date', endDate),
                    const SizedBox(height: 8),
                    Text(
                      'Total Duration: ${days > 0 ? '$days days' : '$hours hours'}',
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPaymentRow('Base Price', '₹${(totalAmount - 5000).toStringAsFixed(0)}'),
                    _buildPaymentRow('Security Deposit', '₹5000'),
                    const Divider(height: 24),
                    _buildPaymentRow(
                      'Total Amount',
                      '₹${totalAmount.toStringAsFixed(0)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isAdminView) ...[
              const Text(
                'Admin Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _confirmDelivery(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm Delivery - Car On The Way',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _cancelBooking(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel Booking',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _downloadReceipt(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Download Receipt',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelivery(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': 'on_the_way',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('cars')
          .doc(car.id)
          .update({
        'isAvailable': false,
        'currentBookingId': bookingId,
      });

      await _sendConfirmationEmail(
        subject: 'Your Car is On The Way!',
        message: 'Your booked car ${car.model} is on the way for delivery.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery confirmed and user notified'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('cars')
          .doc(car.id)
          .update({
        'isAvailable': true,
        'currentBookingId': null,
      });

      await _sendConfirmationEmail(
        subject: 'Booking Cancelled',
        message: 'Your booking for ${car.model} has been cancelled.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled and user notified'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendConfirmationEmail({
    required String subject,
    required String message,
  }) async {
    final bookingDoc = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .get();
    final userEmail = bookingDoc.data()?['userEmail'] as String?;

    if (userEmail == null) return;

    final smtpServer = gmail('morepriyanka187@gmail.com', 'hyme vrqe iokk lf');

    final emailMessage = Message()
      ..from = const Address('morepriyanka187@gmail.com', 'Car Rentals')
      ..recipients.add(userEmail)
      ..subject = subject
      ..text = message;

    try {
      await send(emailMessage, smtpServer);
    } catch (e) {
      debugPrint('Error sending email: $e');
    }
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt downloaded'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 20, color: Colors.teal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTotal ? 16 : null,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : null,
              color: isTotal ? Colors.teal : null,
            ),
          ),
        ],
      ),
    );
  }
}

// booking_service.dart
// booking_service.dart
class BookingService {
  static Future<Booking> getBookingById(String id) async {
    final doc = await FirebaseFirestore.instance.collection('bookings').doc(id).get();
    if (doc.exists) {
      return Booking.fromMap(doc.data()! as String, doc.id as Map<String, dynamic>);
    } else {
      throw Exception('Booking not found');
    }
  }

  static Future<void> cancelBooking(String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({
      'status': 'Cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

// car_service.dart
class CarService {
  static Future<void> updateCarAvailability(String carId, bool isAvailable) async {
    await FirebaseFirestore.instance.collection('cars').doc(carId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

// payment_service.dart
class PaymentService {
  static Future<bool> processRefund(String userId, double amount) async {
    try {
      // This would depend on your payment processor
      // For example, with Stripe you might do:
      // await Stripe.instance.refundPayment(paymentIntentId, amount);

      // For demo purposes, we'll just log it
      print('Refunding $amount to user $userId');
      return true;
    } catch (e) {
      print('Refund failed: $e');
      return false;
    }
  }
}


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

