import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../data/models/car.dart';
import 'PaymentGatewayPage.dart';
import 'BookingConfirmation.dart';

class BookingPage extends StatefulWidget {
  final Car car;
  final String loggedInUserName;

  const BookingPage({
    Key? key,
    required this.car,
    required this.loggedInUserName,
  }) : super(key: key);

  @override
  BookingPageState createState() => BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  late final TextEditingController _nameController;

  bool _termsAccepted = false;
  double _calculatedAmount = 0.0;
  double _rentalCost = 0.0;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isNameEditable = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.loggedInUserName);
    _isNameEditable = widget.loggedInUserName.isEmpty;
    _licenseController.text = '';
    _locationController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    if (_startDate != null && _endDate != null && _endDate!.isAfter(_startDate!)) {
      int totalDays = _endDate!.difference(_startDate!).inDays + 1;
      setState(() {
        _rentalCost = totalDays * widget.car.pricePerDay;
        _calculatedAmount = _rentalCost + (widget.car.securityDeposit ?? 0.0);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          if (_startDate != null && picked.isAfter(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date must be after start date')),
            );
          }
        }
        _calculateAmount();
      });
    }
  }

  Widget _buildDateSelectionField(BuildContext context, {required bool isStartDate}) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate: isStartDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isStartDate
                  ? (_startDate == null
                  ? 'Select Start Date'
                  : DateFormat('MMM dd, yyyy').format(_startDate!))
                  : (_endDate == null
                  ? 'Select End Date'
                  : DateFormat('MMM dd, yyyy').format(_endDate!)),
              style: TextStyle(
                color: (isStartDate ? _startDate : _endDate) == null
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Future<void> _processPaymentAndBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid dates')),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      // First check if car is still available
      final carDoc = await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.car.id)
          .get();

      if (!carDoc.exists || carDoc['isAvailable'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This car is no longer available')),
        );
        return;
      }

      // Process payment first
      final paymentSuccess = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentGatewayPage(
            amount: _calculatedAmount,
            carId: widget.car.id,
            car: widget.car,
            startDate: _startDate!, // Make sure _startDate is not null
            endDate: _endDate!,     // Make sure _endDate is not null
            userName: _nameController.text,
            licenseNumber: _licenseController.text,
            location: _locationController.text,
          ),
        ),
      );

      if (paymentSuccess == true && mounted) {
        await _completeBooking();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  Future<void> _completeBooking() async {
    try {
      // Create booking document
      final bookingRef = FirebaseFirestore.instance.collection('bookings').doc();

      final booking = {
        'id': bookingRef.id,
        'carId': widget.car.id,
        'carModel': widget.car.model,
        'carImage': widget.car.imageUrl,
        'userName': _nameController.text,
        'licenseNumber': _licenseController.text,
        'location': _locationController.text,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'totalPrice': _rentalCost,
        'status': 'confirmed', // Set directly to confirmed after payment
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'securityDeposit': widget.car.securityDeposit ?? 0.0,
        'createdAt': Timestamp.now(),
        'paymentStatus': 'completed',
      };

      // Use a batch to ensure atomic operations
      final batch = FirebaseFirestore.instance.batch();

      // Add booking
      batch.set(bookingRef, booking);

      // Update car availability
      final carRef = FirebaseFirestore.instance.collection('cars').doc(widget.car.id);
      batch.update(carRef, {
        'isAvailable': false,
        'currentBookingId': bookingRef.id,
      });

      // Commit the batch
      await batch.commit();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmation(
            bookingId: bookingRef.id,
            car: widget.car,
            startDate: _startDate!,
            endDate: _endDate!,
            totalAmount: _calculatedAmount,
            securityDeposit: widget.car.securityDeposit ?? 0.0,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}')),
        );
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions', style: TextStyle(color: Colors.teal)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTermItem('1. Rental Agreement',
                  'This agreement constitutes a contract between you and our car rental service.'),
              _buildTermItem('2. Driver Requirements',
                  'You must possess a valid driver\'s license and be at least 21 years old.'),
              _buildTermItem('3. Booking and Payment',
                  'Full payment is required at the time of booking. We accept all major credit cards.'),
              _buildTermItem('4. Cancellation Policy',
                  'Cancellations made 48 hours before pickup will receive a full refund. Late cancellations forfeit 50% of payment.'),
              _buildTermItem('5. Security Deposit',
                  'A security deposit of ₹${widget.car.securityDeposit?.toStringAsFixed(0) ?? '0'} is required and will be refunded after vehicle inspection.'),
              _buildTermItem('6. Fuel Policy',
                  'Vehicle must be returned with the same fuel level as at pickup. Additional charges apply for refueling.'),
              _buildTermItem('7. Damage Responsibility',
                  'You are responsible for any damage to the vehicle during your rental period.'),
              _buildTermItem('8. Prohibited Uses',
                  'Off-road driving, racing, and illegal activities are strictly prohibited.'),
              _buildTermItem('9. Insurance',
                  'Basic insurance is included. Optional premium coverage is available.'),
              _buildTermItem('10. Late Returns',
                  'Late returns will incur additional charges at 1.5x the hourly rate.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.teal)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _termsAccepted = true);
              Navigator.pop(context);
            },
            child: const Text('Accept Terms', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Booking"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: widget.car.imageUrl?.isNotEmpty == true
                            ? Image.network(widget.car.imageUrl!, fit: BoxFit.cover)
                            : Icon(Icons.directions_car, size: 40, color: Colors.teal),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.car.model,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.car.type} • ${widget.car.seats} seats',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${widget.car.pricePerDay}/day',
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              const Text(
                "Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                readOnly: !_isNameEditable,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  filled: true,
                  fillColor: _isNameEditable ? Colors.white : Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseController,
                decoration: InputDecoration(
                  labelText: "Driver's License Number",
                  prefixIcon: const Icon(Icons.card_membership),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  hintText: 'DL-01-2020-1234567',
                  suffixIcon: Tooltip(
                    message: 'Format: DL-01-2020-1234567 or MH02 2020 1234567',
                    child: const Icon(Icons.help_outline),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license number';
                  }
                  if (!RegExp(r'^[A-Z]{2}[-\s]?[0-9]{2}[-\s]?[0-9]{4}[-\s]?[0-9]{7}$').hasMatch(value)) {
                    return 'Invalid license format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Pickup Location",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Booking Dates Section
              const Text(
                "Booking Dates",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDateSelectionField(context, isStartDate: true),
              const SizedBox(height: 16),
              _buildDateSelectionField(context, isStartDate: false),
              const SizedBox(height: 24),

              // Terms and Conditions
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                            activeColor: Colors.teal,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showTermsDialog,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'terms and conditions',
                                      style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Price Summary
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "PRICE SUMMARY",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow("Daily Rate", widget.car.pricePerDay),
                      const Divider(height: 20),
                      if (_startDate != null && _endDate != null)
                        _buildPriceRow(
                            "Rental Days",
                            _endDate!.difference(_startDate!).inDays + 1,
                            isNumeric: true),
                      const Divider(height: 20),
                      _buildPriceRow("Rental Cost", _rentalCost),
                      const Divider(height: 20),
                      _buildPriceRow("Security Deposit", widget.car.securityDeposit ?? 0.0),
                      const Divider(height: 20),
                      _buildPriceRow("Total Amount", _calculatedAmount, isTotal: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : _processPaymentAndBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.teal.withOpacity(0.3),
                  ),
                  child: _isBooking
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white),
                  )
                      : const Text(
                    "PROCEED TO PAYMENT",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic value, {bool isTotal = false, bool isNumeric = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          isNumeric ? '${value.toString()} days' : '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.teal : Colors.black,
          ),
        ),
      ],
    );
  }
}