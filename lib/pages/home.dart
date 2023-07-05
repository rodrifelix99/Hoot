import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:animations/animations.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hoot/pages/feed.dart';
import 'package:hoot/pages/notifications.dart';
import 'package:hoot/pages/profile.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/auth.dart';
import '../services/feed_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    U? user = await Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      if (user.username == null || user.username!.isEmpty) {
        await Navigator.of(context).pushNamed('/welcome');
      }
      await _setFCMToken();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: false,
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return SharedAxisTransition(
            child: child,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
          );
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() {}),
          children: [
            ChangeNotifierProvider<FeedProvider>(
              create: (_) => FeedProvider(),
              child: const FeedPage(),
            ),
            const NotificationsPage(),
            ProfilePage(),
          ],
        ),
      ),
      extendBody: true,
      floatingActionButton: (_pageController.hasClients && _pageController.page!.round() == 0) || !_pageController.hasClients ?
        FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/create'),
        child: const Icon(Icons.add_rounded),
      ) : const SizedBox(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) => setState(() {
          _pageController.jumpToPage(i);
        }),
        currentIndex: _pageController.hasClients ? _pageController.page!.round() : 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.feed_rounded),
            label: AppLocalizations.of(context)!.feed,
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.notifications_rounded),
              label: AppLocalizations.of(context)!.notifications
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: AppLocalizations.of(context)!.profile
          )
        ],
      ),
    );
  }
}
