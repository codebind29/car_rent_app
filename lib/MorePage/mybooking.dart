import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyBookingsPage extends StatefulWidget {
  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<Map<String, dynamic>> bookingRequests = [];
  List<Map<String, dynamic>> confirmedBookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // Fetch booking data from Firestore
  void _loadBookings() async {
    final userId = "currentUserId"; // Replace with actual user ID (e.g., FirebaseAuth instance)

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> requests = [];
    List<Map<String, dynamic>> confirmed = [];

    for (var doc in querySnapshot.docs) {
      var booking = doc.data() as Map<String, dynamic>?; // Cast data to Map<String, dynamic>
      if (booking != null) {
        if (booking['status'] == 'pending') {
          requests.add(booking);
        } else if (booking['status'] == 'confirmed') {
          confirmed.add(booking);
        }
      }
    }

    setState(() {
      bookingRequests = requests;
      confirmedBookings = confirmed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Booking Requests (Pending)
            if (bookingRequests.isNotEmpty)
              SectionHeader(title: "Booking Requests"),
            if (bookingRequests.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bookingRequests.length,
                itemBuilder: (context, index) {
                  var booking = bookingRequests[index];
                  return BookingTile(booking: booking);
                },
              ),

            // Confirmed Bookings
            if (confirmedBookings.isNotEmpty)
              SectionHeader(title: "Confirmed Bookings"),
            if (confirmedBookings.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: confirmedBookings.length,
                itemBuilder: (context, index) {
                  var booking = confirmedBookings[index];
                  return BookingTile(booking: booking);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Widget for each booking tile
class BookingTile extends StatelessWidget {
  final Map<String, dynamic> booking;

  BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(booking['carDetails']['model'] ?? 'Unknown Car'),
        subtitle: Text("Status: ${booking['status']}"),
        trailing: Text(
          "Booking Date: ${booking['bookingDate'].toDate().toLocal()}",
          style: TextStyle(fontSize: 12),
        ),
        onTap: () {
          // Navigate to a detailed booking page if required
        },
      ),
    );
  }
}

// Widget for Section Headers (Booking Requests, Confirmed Bookings)
class SectionHeader extends StatelessWidget {
  final String title;

  SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

