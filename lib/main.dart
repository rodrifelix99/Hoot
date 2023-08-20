import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/about_us.dart';
import 'package:hoot/pages/create_feed.dart';
import 'package:hoot/pages/create_post.dart';
import 'package:hoot/pages/edit_profile.dart';
import 'package:hoot/pages/feed_requests.dart';
import 'package:hoot/pages/home.dart';
import 'package:hoot/pages/post.dart';
import 'package:hoot/pages/profile.dart';
import 'package:hoot/pages/report.dart';
import 'package:hoot/pages/search.dart';
import 'package:hoot/pages/search_by_genre.dart';
import 'package:hoot/pages/settings.dart';
import 'package:hoot/pages/sign_in.dart';
import 'package:hoot/pages/sign_up.dart';
import 'package:hoot/pages/subscriptions_list.dart';
import 'package:hoot/pages/terms.dart';
import 'package:hoot/pages/verify.dart';
import 'package:hoot/pages/welcome.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:hoot/theme/theme.dart';
import 'firebase_options.dart';
import 'package:hoot/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/feed.dart';
import 'models/feed_types.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages here
  // ...
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Request permission for notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Consumer<FeedProvider>(
              builder: (context, feedProvider, _) {
                return MaterialApp(
                  title: 'Hoot',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  supportedLocales: const [
                    Locale('en'),
                    Locale('es'),
                    Locale('pt'),
                    Locale('pt', 'BR'),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    DefaultWidgetsLocalizations.delegate,
                    AppLocalizations.delegate,
                  ],
                  home: AnimatedSplashScreen(
                    nextScreen: HomePage(),
                    splash: 'assets/logo_white.png',
                    backgroundColor: Theme.of(context).primaryColor,
                    splashTransition: SplashTransition.slideTransition,
                    pageTransitionType: PageTransitionType.rightToLeft,
                  ),
                  onGenerateRoute: (settings) {
                    switch (settings.name) {
                      case '/login':
                        return MaterialPageRoute(builder: (context) => LoginPage());
                      case '/home':
                        return MaterialPageRoute(builder: (context) => HomePage());
                      case '/signup':
                        return MaterialPageRoute(builder: (context) => SignUpPage());
                      case '/signin':
                        return MaterialPageRoute(builder: (context) => SignInPage());
                      case '/verify':
                        return MaterialPageRoute(builder: (context) => VerifyPage());
                      case '/terms_of_service':
                        return MaterialPageRoute(builder: (context) => TermsOfService());
                      case '/welcome':
                        return MaterialPageRoute(builder: (context) => WelcomePage());
                      case '/create_post':
                        final String? feedId = settings.arguments as String?;
                        return MaterialPageRoute(
                            builder: (context) => CreatePostPage(feedId: feedId));
                      case '/settings':
                        return MaterialPageRoute(builder: (context) => SettingsPage());
                      case '/profile':
                        if (settings.arguments == null) {
                          return MaterialPageRoute(builder: (context) => ProfilePage());
                        } else if (settings.arguments.runtimeType != String && settings.arguments.runtimeType != U) {
                          final List<dynamic> args = settings.arguments as List<dynamic>;
                          final U user = args[0] as U;
                          final String feedId = args[1] as String;
                          return MaterialPageRoute(builder: (context) => ProfilePage(user: user, feedId: feedId));
                        } else if (settings.arguments.runtimeType == String) {
                          final String feedId = settings.arguments as String;
                          return MaterialPageRoute(builder: (context) => ProfilePage(feedId: feedId));
                        } else {
                          final U user = settings.arguments as U;
                          return MaterialPageRoute(builder: (context) => ProfilePage(user: user));
                        }
                      case '/edit_profile':
                        return MaterialPageRoute(builder: (context) => EditProfilePage());
                      case '/search':
                        return MaterialPageRoute(builder: (context) => SearchPage());
                        case '/search_by_genre':
                          final FeedType type = settings.arguments as FeedType;
                          return MaterialPageRoute(builder: (context) => SearchByGenrePage(type: type));
                      case '/create_feed':
                        return MaterialPageRoute(builder: (context) => CreateFeedPage());
                      case '/edit_feed':
                        final Feed feed = settings.arguments as Feed;
                        return MaterialPageRoute(builder: (context) => CreateFeedPage(feed: feed));
                      case '/feed_requests':
                        final String feedId = settings.arguments as String;
                        return MaterialPageRoute(builder: (context) => FeedRequestsPage(feedId: feedId));
                        case '/subscriptions':
                          final String userId = settings.arguments as String;
                          return MaterialPageRoute(builder: (context) => SubscriptionsListPage(userId: userId));
                      case '/post':
                        if (settings.arguments.runtimeType != Post) {
                          // get userId, feedId and postId from arguments
                          final List<dynamic> args = settings.arguments as List<dynamic>;
                          final String userId = args[0] as String;
                          final String feedId = args[1] as String;
                          final String postId = args[2] as String;
                          return MaterialPageRoute(builder: (context) => PostPage(userId: userId, feedId: feedId, postId: postId));
                        } else {
                          final Post post = settings.arguments as Post;
                          return MaterialPageRoute(
                              builder: (context) => PostPage(post: post));
                        }
                      case '/report':
                        final List<dynamic> args = settings.arguments as List<dynamic>;
                        final U user = args[0] as U;
                        final String postId = args.length >= 2 ? args[1] as String : '';
                        final String feedId = args.length >= 3 ? args[2] as String : '';
                        return MaterialPageRoute(builder: (context) => ReportPage(user: user, postId: postId, feedId: feedId));
                      case '/about_us':
                        return MaterialPageRoute(builder: (context) => AboutUsPage());
                      default:
                        return MaterialPageRoute(builder: (context) => HomePage());
                    }
                  },
                );
              },
            );
          }),
    ),
  );
}
