import 'package:animations/animations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/pages/feed.dart';
import 'package:hoot/pages/notifications.dart';
import 'package:hoot/pages/profile.dart';
import 'package:line_icons/line_icons.dart';
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
      bottomNavigationBar: GNav(
        onTabChange: (i) => setState(() {
          _pageController.jumpToPage(i);
        }),
        selectedIndex: _pageController.hasClients ? _pageController.page!.round() : 0,
        haptic: true,
        gap: 8,
        backgroundColor: Theme.of(context).colorScheme.surface,
        tabBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        activeColor: Theme.of(context).colorScheme.onSurface,
        tabMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tabs: [
          GButton(
              icon: LineIcons.home,
              text: AppLocalizations.of(context)!.myFeeds,
              padding: const EdgeInsets.all(16)
          ),
          GButton(
              icon: LineIcons.bell,
              text: AppLocalizations.of(context)!.notifications,
              leading: Badge(
                label: Text('3'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                child: Icon(
                  LineIcons.bell,
                ),
              ),
              padding: const EdgeInsets.all(16)
          ),
          GButton(
            leading: Provider.of<AuthProvider>(context).user?.smallProfilePictureUrl != null ?
            ProfileAvatar(image: Provider.of<AuthProvider>(context).user!.smallProfilePictureUrl ?? '', size: 24) : null,
              icon: LineIcons.user,
              text: AppLocalizations.of(context)!.profile,
              padding: const EdgeInsets.all(16)
          ),
        ],
      ),
    );
  }
}
