import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/create_feed.dart';
import 'package:hoot/pages/create_post.dart';
import 'package:hoot/pages/edit_profile.dart';
import 'package:hoot/pages/feed_requests.dart';
import 'package:hoot/pages/home.dart';
import 'package:hoot/pages/profile.dart';
import 'package:hoot/pages/search.dart';
import 'package:hoot/pages/sign_in.dart';
import 'package:hoot/pages/sign_up.dart';
import 'package:hoot/pages/subscriptions_list.dart';
import 'package:hoot/pages/terms.dart';
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages here
  // ...
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'), // English
                  ],
                  home: AnimatedSplashScreen(
                    nextScreen: authProvider.isSignedIn ? HomePage() : LoginPage(),
                    splash: Image.asset('assets/logo.png'),
                    splashTransition: SplashTransition.fadeTransition,
                    backgroundColor: Theme.of(context).colorScheme.background,
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
                      case '/terms_of_service':
                        return MaterialPageRoute(builder: (context) => TermsOfService());
                      case '/welcome':
                        return MaterialPageRoute(builder: (context) => WelcomePage());
                      case '/create_post':
                        final String? feedId = settings.arguments as String?;
                        return MaterialPageRoute(
                            builder: (context) => CreatePostPage(feedId: feedId));
                      case '/profile':
                        final U user = settings.arguments as U;
                        return MaterialPageRoute(builder: (context) => ProfilePage(user: user));
                      case '/edit_profile':
                        return MaterialPageRoute(builder: (context) => EditProfilePage());
                      case '/search':
                        return MaterialPageRoute(builder: (context) => SearchPage());
                      case '/create_feed':
                        return MaterialPageRoute(builder: (context) => CreateFeedPage());
                      case '/edit_feed':
                        final Feed feed = settings.arguments as Feed;
                        return MaterialPageRoute(builder: (context) => CreateFeedPage(feed: feed));
                      case '/feed_requests':
                        final int feedIndex = settings.arguments as int;
                        return MaterialPageRoute(builder: (context) => FeedRequestsPage(feedIndex: feedIndex));
                        case '/subscriptions':
                          final String userId = settings.arguments as String;
                          return MaterialPageRoute(builder: (context) => SubscriptionsListPage(userId: userId));
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
