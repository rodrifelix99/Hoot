import 'dart:async';

import 'package:animations/animations.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/radio_component.dart';
import 'package:hoot/pages/explore.dart';
import 'package:hoot/pages/feed.dart';
import 'package:hoot/pages/notifications.dart';
import 'package:hoot/pages/profile.dart';
import 'package:hoot/pages/radio.dart';
import 'package:hoot/services/radio_controller.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/user.dart';
import '../services/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'create_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final RadioController _radioController = Get.put(RadioController());
  late PageController _pageController;
  late AuthProvider _authProvider;
  late StreamSubscription<RemoteMessage> _messageStreamSubscription;
  late VoidCallback _authProviderListener = () {};
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool _loading = true;

  Future _setFCMToken() async {
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      await _authProvider.setFCMToken(fcmToken);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await _authProvider.setFCMToken(fcmToken);
    });
  }

  Future _checkTrackingStatus() async {
    if (await AppTrackingTransparency.trackingAuthorizationStatus ==
        TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  Future isNewUser() async {
    U? user = _authProvider.user;
    if (user != null) {
      if (user.username == null || user.username!.isEmpty) {
        await Navigator.of(context).pushNamed('/welcome');
      } else {
        await _countUnreadNotifications();
      }
      await _setFCMToken();
      await _checkTrackingStatus();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future _countUnreadNotifications() async {
    await _authProvider.countUnreadNotifications();
    setState(() {});
  }

  void onShake() {
    print("Shakezão");
  }

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pageController = PageController();
    super.initState();
    ShakeDetector.autoStart(
        onPhoneShake: onShake,
    );
    _messageStreamSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      _countUnreadNotifications();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isSignedIn = _authProvider.isSignedIn;
      if (!isSignedIn) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        isNewUser();
        _loading = false;
        _authProviderListener = () async {
          if (!_authProvider.isSignedIn) {
            await Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        };
        _authProvider.addListener(_authProviderListener);
      }
    });
  }

  _openRadio() {
    _radioController.closeRadio.value = false;
    _radioController.onInit();
  }

  _closeRadio() {
    _radioController.closeRadio.value = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _countUnreadNotifications();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _authProvider.removeListener(_authProviderListener);
    _messageStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? Container() : Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: false,
        transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() {}),
                children: [
                  FeedPage(toggleRadio: _openRadio),
                  ExplorePage(),
                  CreatePostPage(),
                  NotificationsPage(),
                  ProfilePage(),
                ],
              ),
            ),
            Obx(() => _radioController.closeRadio.isFalse ? Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: OpenContainer(
                  closedElevation: 10,
                  closedColor: Colors.transparent,
                  transitionType: ContainerTransitionType.fadeThrough,
                  closedBuilder: (context, open) => RadioComponent(),
                  openBuilder: (context, close) => RadioPage(closeRadio: _closeRadio),
                ),
            ) : const Positioned(bottom: 0, child: SizedBox.shrink())),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        child: BottomNavigationBar(
          currentIndex: _pageController.hasClients ? _pageController.page!.round() : 0,
          onTap: (i) => i != 2 ? setState(() {
            _pageController.jumpToPage(i);
          }) : null,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          iconSize: 28,
          elevation: 5,
          items: [
            BottomNavigationBarItem(
              icon: _pageController.hasClients && _pageController.page!.round() == 0 ?
                const Icon(SolarIconsBold.feed) : const Icon(SolarIconsOutline.feed),
              label: AppLocalizations.of(context)!.myFeeds,
            ),
            BottomNavigationBarItem(
              icon: _pageController.hasClients && _pageController.page!.round() == 1 ?
                const Icon(SolarIconsBold.compass) : const Icon(SolarIconsOutline.compass),
              label: AppLocalizations.of(context)!.explore,
            ),
            BottomNavigationBarItem(
              icon: OpenContainer(
                closedElevation: 0,
                closedColor: Colors.transparent,
                transitionType: ContainerTransitionType.fadeThrough,
                openColor: Colors.transparent,
                openElevation: 0,
                closedBuilder: (context, open) => Icon(
                    SolarIconsBold.addSquare,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
                openBuilder: (context, close) => CreatePostPage(),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  _pageController.hasClients && _pageController.page!.round() == 3 ?
                    const Icon(SolarIconsBold.bell) : const Icon(SolarIconsOutline.bell),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _authProvider.notificationsCount > 0 ? Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _authProvider.notificationsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ) : const SizedBox()),
                ],
              ),
              label: AppLocalizations.of(context)!.notifications,
            ),
            BottomNavigationBarItem(
              icon: _pageController.hasClients && _pageController.page!.round() == 4 ?
                const Icon(SolarIconsBold.userCircle) : const Icon(SolarIconsOutline.userCircle),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
        ),
      ),
    );
  }
}
