import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'car_list_screen_with_city_filter.dart';

class DifferentCityScreen extends StatelessWidget {
  final List<String> cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Jaipur',
    'Ahmedabad',
    'Goa'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select City'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(Icons.location_city, color: Colors.teal),
              title: Text(cities[index]),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarListScreenWithCityFilter(city: cities[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}