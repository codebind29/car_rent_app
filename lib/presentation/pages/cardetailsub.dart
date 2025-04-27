import 'package:flutter/material.dart';

class CarDetailPage extends StatelessWidget {


  final String carName;
  final String fuelType;
  final String transmission;
  final String availabilityDate;
  final String price;
  final String oldPrice;

  const CarDetailPage({
    super.key,
    required this.carName,
    required this.fuelType,
    required this.transmission,
    required this.availabilityDate,
    required this.price,
    required this.oldPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Car Details',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)], // Teal to Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    carName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_gas_station, color: Color(0xFFFFA726), size: 20),
                      const SizedBox(width: 5),
                      Text(fuelType, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 15),
                      const Icon(Icons.settings, color: Color(0xFFFFA726), size: 20),
                      const SizedBox(width: 5),
                      Text(transmission, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available from $availabilityDate',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '₹$price/month',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0072FF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '₹$oldPrice',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our Journey so far',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _StatItem(
                        icon: Icons.emoji_emotions_outlined,
                        label: '2500+',
                        subtitle: 'Happy Subscribers',
                      ),
                      _StatItem(
                        icon: Icons.location_on_outlined,
                        label: '22+ Cities',
                        subtitle: 'Across India',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _StatItem(
                        icon: Icons.directions_car_outlined,
                        label: '5000+ years',
                        subtitle: 'Subscriptions Booked',
                      ),
                      _StatItem(
                        icon: Icons.star_border_outlined,
                        label: '4.7 / 5',
                        subtitle: 'Customer Rating',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Call logic
                    },
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text('Call us'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00C6FF),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Sort logic
                        },
                        icon: const Icon(Icons.sort, color: Color(0xFF0072FF)),
                      ),
                      IconButton(
                        onPressed: () {
                          // Filter logic
                        },
                        icon: const Icon(Icons.filter_list, color: Color(0xFF0072FF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Color(0xFF00C6FF)),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
        ),
      ],
    );
  }
}
