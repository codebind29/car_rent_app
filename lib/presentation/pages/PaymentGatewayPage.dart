import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/car.dart';

class PaymentGatewayPage extends StatefulWidget {
  final double amount;
  final String carId;
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final String userName;
  final String licenseNumber;
  final String location;

  const PaymentGatewayPage({
    super.key,
    required this.amount,
    required this.carId,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.userName,
    required this.licenseNumber,
    required this.location,
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  bool _isProcessing = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _upiIdController = TextEditingController();
  String? _transactionId;

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  Future<bool> _verifyCarAvailability() async {
    final carDoc = await _firestore.collection('cars').doc(widget.carId).get();
    return carDoc.exists && carDoc['isAvailable'] == true;
  }

  Future<String> _createPaymentRecord() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final paymentRef = _firestore.collection('payments').doc();
    _transactionId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';

    await paymentRef.set({
      'id': paymentRef.id,
      'transactionId': _transactionId,
      'userId': user.uid,
      'carId': widget.carId,
      'amount': widget.amount,
      'status': 'pending',
      'paymentMethod': 'UPI',
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': {
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'userName': widget.userName,
        'licenseNumber': widget.licenseNumber,
        'location': widget.location,
      }
    });

    return paymentRef.id;
  }

  Future<void> _updatePaymentStatus(String paymentId, bool success) async {
    await _firestore.collection('payments').doc(paymentId).update({
      'status': success ? 'completed' : 'failed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _initiateUPIPayment() async {
    if (_upiIdController.text.isEmpty || !_upiIdController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid UPI ID")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Verify car availability
      if (!await _verifyCarAvailability()) {
        throw Exception("Car is no longer available");
      }

      // 2. Create payment record
      final paymentId = await _createPaymentRecord();

      // 3. Simulate UPI payment
      const merchantUpiId = "9322979933@kotak811";
      final upiUrl = Uri.parse(
        "upi://pay?pa=$merchantUpiId"
            "&pn=CarRent"
            "&am=${widget.amount.toStringAsFixed(2)}"
            "&cu=INR"
            "&tn=CarRental-${_transactionId}",
      );

      if (await canLaunchUrl(upiUrl)) {
        await launchUrl(upiUrl);

        // Simulate payment verification (in real app, use webhook or cloud function)
        await Future.delayed(const Duration(seconds: 2));

        // 4. Mark payment as completed
        await _updatePaymentStatus(paymentId, true);

        // 5. Return success
        if (mounted) Navigator.pop(context, true);
      } else {
        await _updatePaymentStatus(paymentId, false);
        throw Exception("Could not launch UPI app");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Gateway"),
        leading: _isProcessing
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.payment, size: 60, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              "₹${widget.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Total Payment Amount"),
            const SizedBox(height: 30),

            // Car Info Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.model,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(widget.startDate)} - '
                          '${DateFormat('MMM dd, yyyy').format(widget.endDate)}',
                    ),
                    const SizedBox(height: 8),
                    Text("Pickup: ${widget.location}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Payment Method Selection
            const Text(
              "Pay Using UPI",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                hintText: 'yourname@upi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
            ),
            const SizedBox(height: 30),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _initiateUPIPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "PROCEED TO PAYMENT",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}