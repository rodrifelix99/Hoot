import 'package:flutter/material.dart';
import 'package:hoot/pages/about_your_data.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Terms of Service & Privacy Policy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutYourDataPage()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Terms of Service',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Insert your Terms of Service content here...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'Privacy Policy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Insert your Privacy Policy content here...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      )
    );
  }
}
