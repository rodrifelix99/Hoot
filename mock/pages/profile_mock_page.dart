import 'package:flutter/material.dart';

import '../data/mock_user.dart';

class ProfileMockPage extends StatelessWidget {
  const ProfileMockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mockUser.name ?? 'Mock User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('@${mockUser.username}'),
          ],
        ),
      ),
    );
  }
}
