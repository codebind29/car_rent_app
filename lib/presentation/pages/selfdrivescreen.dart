import 'package:flutter/material.dart';
import 'car_list_screen.dart'; // Import the CarListScreen file

class SelfDriveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to CarListScreen when clicked
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarListScreen()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Self Drive Options'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, size: 50, color: Colors.teal),
                SizedBox(height: 10),
                Text(
                  'Tap to view available self-drive cars!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


