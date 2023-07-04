import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hoot/pages/notifications.dart';
import 'package:hoot/pages/profile.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future _setFCMToken() async {
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      await Provider.of<AuthProvider>(context, listen: false).setFCMToken(fcmToken);
    }
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
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  Future _signOut() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  String _appBarText() {
    if (_pageController.hasClients) {
      switch (_pageController.page!.round()) {
        case 0:
          return 'Home';
        case 1:
          return 'Notifications';
        case 2:
          return 'Profile';
        default:
          return 'Hoot';
      }
    } else {
      return 'Hoot';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarText()),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomePage(),
          NotificationsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) => _pageController.jumpToPage(i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Notifications'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile'
          )
        ],
      ),
    );
  }
}
