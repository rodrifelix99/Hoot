import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final TextEditingController _fcmController = TextEditingController();

  Future _setFCMToken() async {
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) async {
      await Provider.of<AuthProvider>(context, listen: false).setFCMToken(fcmToken);
    });
  }

  Future isNewUser() async {
    bool isNewUser = Provider.of<AuthProvider>(context, listen: false).user!.username == null;
    if (isNewUser) {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    } else {
      _setFCMToken();
    }
  }

  @override
  void initState() {
    bool isSignedIn = Provider.of<AuthProvider>(context, listen: false).isSignedIn;
    if (!isSignedIn) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      isNewUser();
    }

    super.initState();
  }

  Future _signOut() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future _sendTestNotification() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).sendTestNotification(_fcmController.text);
    } catch (e) {
      print(e);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Impossible to send test notification", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onError)),
                backgroundColor: Theme.of(context).colorScheme.error
            )
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          TextField(
            onSubmitted: (value) => _sendTestNotification(),
            decoration: const InputDecoration(
              labelText: 'FCMToken',
            ),
            controller: _fcmController,
          ),
          ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false),
          child: Text('Sign Out'),
        ),
        ]
      ),
    );
  }
}
