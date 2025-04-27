import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShareFeedbackPage extends StatefulWidget {
  const ShareFeedbackPage({super.key});

  @override
  _ShareFeedbackPageState createState() => _ShareFeedbackPageState();
}

class _ShareFeedbackPageState extends State<ShareFeedbackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _feedbackController = TextEditingController();

  // Save feedback to Firestore
  void _saveFeedback() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Collect feedback data
      String feedback = _feedbackController.text.trim();

      if (feedback.isNotEmpty) {
        // Save feedback in Firestore under 'feedback' collection
        await _firestore.collection('feedback').add({
          'userId': user.uid,
          'feedback': feedback,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thank you for your feedback!')),
        );
        _feedbackController.clear();
      } else {
        // Show error message if feedback is empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your feedback.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Your Feedback'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Text
            Text(
              'We value your feedback!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),

            // Instructions Text
            Text(
              'Please share your thoughts or suggestions to help us improve the app.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Feedback TextField
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
                hintText: 'What can we do better?',
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _saveFeedback,
                child: Text('Submit Feedback'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
