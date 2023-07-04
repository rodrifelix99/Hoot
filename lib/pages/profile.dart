import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hoot/services/auth.dart';
import 'package:hoot/models/user.dart';
import 'package:octo_image/octo_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late U _user;

  @override
  void initState() {
    _user = Provider.of<AuthProvider>(context, listen: false).user!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            OctoImage(
                image: NetworkImage(_user.largeProfilePictureUrl!),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                placeholderBuilder: OctoPlaceholder.blurHash(
                  'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                ),
              errorBuilder: OctoError.icon(color: Colors.red),
              imageBuilder: OctoImageTransformer.circleAvatar(),
            ),
            const SizedBox(height: 20),
            Text(
              _user.name!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _user.username!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sign Out'),
            ),
          ],
        ),
      )
    );
  }
}
