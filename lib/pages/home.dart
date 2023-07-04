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

  Future _setFCMToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        bool success = await Provider.of<AuthProvider>(context, listen: false).setFCMToken(token);
        if (!success) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Impossible to register for push notifications on the server", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onError)),
                    backgroundColor: Theme.of(context).colorScheme.error
                )
            );
          });
        }
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("No FCM token available", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onError)),
                  backgroundColor: Theme.of(context).colorScheme.error
              )
          );
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Impossible to register for push notifications", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onError)),
                backgroundColor: Theme.of(context).colorScheme.error
            )
        );
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false),
          child: Text('Sign Out'),
        ),
      ),
    );
  }
}
