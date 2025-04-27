import 'package:car_rent/presentation/pages/selfdrivescreen.dart';
import 'package:car_rent/presentation/pages/withdriverscreen.dart';
import 'package:flutter/material.dart';
import 'car_list_screen_with_city_filter.dart';
import 'diffrentcityscreen.dart';

class HomeContent extends StatelessWidget {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rentals Section (Header)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      bottom: 40,
                      left: 25,
                      right: 25,
                    ),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rentals',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 23),
                        Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildRentalTypeButton(
                              context,
                              'Self Drive',
                              Icons.directions_car,
                              Colors.white,
                              Colors.teal,
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelfDriveScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildRentalTypeButton(
                              context,
                              'With Driver',
                              Icons.person,
                              Colors.white,
                              Colors.orange,
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WithDriverScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 23),
                        _buildSearchField(context),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DifferentCityScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Want to book in a different city?',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Features Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSectionTitle('Features', Icons.star, Colors.amber),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            children: [
                              SizedBox(width: 10),
                              _buildFeaturedCard(
                                '10% off for new users',
                                'Bangalore, Mumbai, Hyderabad, Chennai, Kolkata',
                                Icons.face,
                                Colors.purple,
                                    () => _showFeatureDetails(
                                    context,
                                    'New User Discount',
                                    'Get 10% off on your first booking. Valid in selected cities only.'),
                              ),
                              _buildFeaturedCard(
                                '5% off on 3+ days',
                                'Discount on longer rentals',
                                Icons.local_offer,
                                Colors.red,
                                    () => _showFeatureDetails(
                                    context,
                                    'Extended Rental Discount',
                                    'Book for 3 or more days and get 5% discount.'),
                              ),
                              _buildFeaturedCard(
                                'Sanitised Cars',
                                '₹675/day with doorstep delivery',
                                Icons.cleaning_services,
                                Colors.green,
                                    () => _showFeatureDetails(context, 'Sanitized Cars',
                                    'All cars are thoroughly sanitized before each rental.'),
                              ),
                              _buildFeaturedCard(
                                '24/7 Support',
                                'Roadside assistance available',
                                Icons.support_agent,
                                Colors.blue,
                                    () => _showFeatureDetails(context, '24/7 Support',
                                    'Our support team is available round the clock for any assistance.'),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Why Choose Us Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _buildWhyChooseUsSection(),
                  ),

                  // FAQs Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _buildFAQsSection(),
                  ),

                  // Testimonials Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _buildTestimonialsSection(),
                  ),

                  // Rating Section
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: _buildRatingSection(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRentalTypeButton(BuildContext context, String text, IconData icon,
      Color textColor, Color bgColor, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 3,
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: _cityController,
        decoration: InputDecoration(
          hintText: 'Search in Pune',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.location_on, color: Colors.teal),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: Colors.teal),
            onPressed: () {
              if (_cityController.text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CarListScreenWithCityFilter(city: _cityController.text),
                  ),
                );
              }
            },
          ),
        ),
        cursorColor: Colors.teal,
        style: TextStyle(color: Colors.black),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarListScreenWithCityFilter(city: value),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData? icon, Color? iconColor) {
    return Row(
      children: [
        if (icon != null)
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(
      String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhyChooseUsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionTitle('Why Choose Us?', Icons.thumb_up, Colors.blue),
            SizedBox(height: 15),
            _buildFeatureItem(
              Icons.home,
              'Home Delivery',
              'Get the car delivered to your doorstep',
              Colors.teal,
            ),
            _buildFeatureItem(
              Icons.attach_money,
              'Flexible Pricing',
              'Choose from various pricing plans',
              Colors.orange,
            ),
            _buildFeatureItem(
              Icons.car_repair,
              'Well Maintained',
              'Regularly serviced and inspected cars',
              Colors.green,
            ),
            _buildFeatureItem(
              Icons.support_agent,
              '24/7 Support',
              'Round the clock assistance',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
    );
  }

  Widget _buildFAQsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionTitle('FAQs', Icons.help, Colors.blue),
            SizedBox(height: 10),
            _buildFAQItem(
              'Is there a speed limit?',
              'Rentapp allows up to 125 km/hr. However, it is 80 km/hr in a few cities where some cars might be equipped with speed governors as per government directives.',
            ),
            _buildFAQItem(
              'Can I extend/cancel/modify?',
              'Yes, extensions are possible subject to availability & charges. Cancellations & modifications will attract nominal charges as per our policy.',
            ),
            _buildFAQItem(
              'Booking criteria & documents?',
              'Min. 21 years old, have a valid original government ID (Aadhar or Passport) and an original hard copy or a DigiLocker of a driving license.',
            ),
            TextButton(
              onPressed: () {},
              child: Text('View all FAQs'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionTitle('Happy Customers', Icons.people, Colors.purple),
            SizedBox(height: 15),
            _buildTestimonialItem(
              'Prateek Srivastava',
              'Nice service with on time pickup and delivery. Good customer support with friendly and very helpful staff. The car was also very smooth and the packages are pocket friendly.',
              5,
            ),
            _buildTestimonialItem(
              'Anjali Sharma',
              'Amazing experience! The car was clean and well-maintained. The pickup and drop process was very smooth. Will definitely use again.',
              4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialItem(String name, String review, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.person, color: Colors.white),
              backgroundColor: Colors.teal,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(review, style: TextStyle(fontSize: 14)),
        Divider(height: 30),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '4.5',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < 4 ? Icons.star : Icons.star_half,
                  color: Colors.amber,
                  size: 24,
                );
              }),
            ),
            SizedBox(height: 10),
            Text(
              'Highest rated self-drive car rental service in India',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              child: Text('Read Reviews'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureDetails(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}