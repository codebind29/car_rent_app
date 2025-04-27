import 'package:flutter/material.dart';

class WithDriverScreen extends StatelessWidget {
  final bool isDriverAvailable = false; // Change this based on availability

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('With Driver Options'),
        backgroundColor: Colors.orange,
      ),
      body: isDriverAvailable ? _buildServiceList() : _buildNoDriverMessage(),
    );
  }

  Widget _buildServiceList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildServiceOption(
          'Airport Transfer',
          'Hassle-free airport pickups and drops',
          Icons.airplanemode_active,
          Colors.blue,
        ),
        _buildServiceOption(
          'City Rides',
          'Explore the city with our drivers',
          Icons.location_city,
          Colors.green,
        ),
        _buildServiceOption(
          'Outstation Trips',
          'Comfortable long-distance travel',
          Icons.directions_car,
          Colors.purple,
        ),
        _buildServiceOption(
          'Hourly Rental',
          'Flexible hourly packages',
          Icons.timer,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildNoDriverMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
          SizedBox(height: 20),
          Text(
            'Currently, no drivers are available.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Please check back later or try self-drive options.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Handle navigation
        },
      ),
    );
  }
}
