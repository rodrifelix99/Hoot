import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/radio_component.dart';
import 'package:hoot/pages/explore.dart';
import 'package:hoot/pages/feed.dart';
import 'package:hoot/pages/notifications.dart';
import 'package:hoot/pages/profile.dart';
import 'package:hoot/pages/radio.dart';
import 'package:hoot/services/radio_controller.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';
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

  Future isNewUser() async {
    U? user = _authProvider.user;
    if (user != null) {
      if (user.username == null || user.username!.isEmpty) {
        await Navigator.of(context).pushNamed('/welcome');
      } else {
        await _countUnreadNotifications();
      }
      await _setFCMToken();
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
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
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
      floatingActionButton: (_pageController.hasClients && _pageController.page!.round() == 0) || !_pageController.hasClients ?
      OpenContainer(
        closedColor: Colors.transparent,
          closedElevation: 10,
          closedShape: const CircleBorder(),
          closedBuilder: (context, open) => Obx(() => Padding(
            padding: _radioController.closeRadio.isFalse ? const EdgeInsets.only(bottom: 70) : EdgeInsets.zero,
            child: FloatingActionButton(
              onPressed: null,
              child: const LineIcon(LineIcons.alternateFeather),
            ),
          )),
          openBuilder: (context, close) => CreatePostPage(),
      ) : const SizedBox(),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          bottom: true,
          child: GNav(
            onTabChange: (i) => setState(() {
              _pageController.jumpToPage(i);
            }),
            selectedIndex: _pageController.hasClients ? _pageController.page!.round() : 0,
            haptic: true,
            gap: 8,
            backgroundColor: Theme.of(context).colorScheme.surface,
            tabBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            activeColor: Theme.of(context).colorScheme.onSurface,
            tabMargin: const EdgeInsets.all(10),
            tabs: [
              GButton(
                  icon: LineIcons.feather,
                  text: AppLocalizations.of(context)!.myFeeds,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              ),
              GButton(
                  icon: LineIcons.compass,
                  text: AppLocalizations.of(context)!.explore,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              ),
              GButton(
                  icon: LineIcons.bell,
                  text: AppLocalizations.of(context)!.notifications,
                  leading: _authProvider.notificationsCount > 0 ? Badge(
                    label: Text( _authProvider.notificationsCount > 30 ? '30+' :  _authProvider.notificationsCount.toString()),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    child: const Icon(
                      LineIcons.bell,
                    ),
                  ) : const Icon(
                    LineIcons.bell,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              ),
              GButton(
                  leading: Provider.of<AuthProvider>(context).user?.smallProfilePictureUrl != null ?
                  ProfileAvatar(image: Provider.of<AuthProvider>(context).user!.smallProfilePictureUrl ?? '', size: 24) : null,
                  icon: LineIcons.user,
                  text: AppLocalizations.of(context)!.profile,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
