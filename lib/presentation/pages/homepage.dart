import 'package:flutter/material.dart';
import 'package:car_rent/presentation/pages/BookingConfirmation.dart';
import 'package:car_rent/presentation/pages/car_list_screen.dart';
import 'package:car_rent/presentation/pages/subscriptions_page.dart';
import 'homecontent.dart';
import 'morepage.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages for footer navigation
  final List<Widget> _pages = [
    HomeContent(),
    SubscriptionPage(),
    BookingsListScreen(),
    CarListScreen(),
    MorePage(),
  ];



  // Method to update the selected index on tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to build the footer with icons
  Widget _FooterItem({
    required IconData icon,
    required String label,
    required Color color,
    bool notification = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: color,
              size: 24.0,
            ),
            if (notification)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(width: 2.0, color: Colors.white),
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    "NEW",
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _onItemTapped(0),
              child: _FooterItem(
                icon: Icons.directions_car,
                label: "Rentals",
                color: _selectedIndex == 0 ? Colors.teal : Colors.grey.shade400,
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(1),
              child: _FooterItem(
                icon: Icons.sync_alt,
                label: "Subscriptions",
                color: _selectedIndex == 1 ? Colors.teal : Colors.grey.shade400,
                notification: true,
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: _FooterItem(
                icon: Icons.calendar_today,
                label: "Bookings",
                color: _selectedIndex == 2 ? Colors.teal : Colors.grey.shade400,
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(3),
              child: _FooterItem(
                icon: Icons.directions_car, // Car icon for Car List Screen
                label: "Car List",
                color: _selectedIndex == 3 ? Colors.teal : Colors.grey.shade400,
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(4),
              child: _FooterItem(
                icon: Icons.menu,
                label: "More",
                color: _selectedIndex == 4 ? Colors.teal : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Method to build the footer with icons
Widget _FooterItem({
  required IconData icon,
  required String label,
  required Color color,
  bool notification = false,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: color,
            size: 24.0,
          ),
          if (notification)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(width: 2.0, color: Colors.white),
                ),
                padding: EdgeInsets.all(4.0),
                child: Text(
                  "NEW",
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      SizedBox(height: 4.0),
      Text(
        label,
        style: TextStyle(
          fontSize: 12.0,
          color: color,
        ),
      ),
    ],
  );
}




// Placeholder for other pages


/*
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepPurple, // Set your app's primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white, // Match the Login page background
        textTheme: TextTheme(
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black), // Regular text
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages for Bottom Navigation
  final List<Widget> _pages = [
    HomeContent(),
    SubscriptionsPage(),
    Bookingconfirmation(),
    CarListScreen(),
    MorePage(),
  ];


  // Method to update the selected index on tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to build gradient icons
  Widget _buildGradientIcon(IconData iconData, int index) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: _selectedIndex == index
              ? [Colors.teal, Colors.white] // Apply gradient for selected
              : [Colors.transparent, Colors.grey], // Transparent for unselected
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Icon(iconData, size: 30, color: _selectedIndex == index ? null : Colors.grey), // Apply gradient or default color
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.car_rental, 0),
            label: 'Rentals',
          ),
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.subscriptions, 1),
            label: 'Subscriptions',
          ),
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.book_online, 2),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.directions_car, 3),
            label: 'Car List',
          ),
          BottomNavigationBarItem(
            icon: _buildGradientIcon(Icons.more_horiz, 4),
            label: 'More',
          ),
        ],
        selectedItemColor: Colors.deepPurple[200],
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        iconSize: 30, // Adjust icon size
      ),
    );
  }
}*/


