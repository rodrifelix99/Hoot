import 'package:get/get.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:hoot/pages/about_us.dart';
import 'package:hoot/pages/contacts.dart';
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
import 'package:hoot/pages/subscribers_list.dart';
import 'package:hoot/pages/subscriptions_list.dart';
import 'package:hoot/pages/terms.dart';
import 'package:hoot/pages/verify.dart';
import 'package:hoot/pages/welcome.dart';
import 'package:hoot/pages/login.dart';
import 'package:hoot/models/feed_types.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/app/routes/app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.signup, page: () => const SignUpPage()),
    GetPage(name: AppRoutes.signin, page: () => const SignInPage()),
    GetPage(name: AppRoutes.verify, page: () => const VerifyPage()),
    GetPage(name: AppRoutes.terms, page: () => const TermsOfService()),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
    GetPage(name: AppRoutes.createPost, page: () => const CreatePostPage()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfilePage()),
    GetPage(name: AppRoutes.search, page: () => const SearchPage()),
    GetPage(name: AppRoutes.searchByGenre, page: () => const SearchByGenrePage(type: FeedType.general)),
    GetPage(name: AppRoutes.createFeed, page: () => const CreateFeedPage()),
    GetPage(name: AppRoutes.editFeed, page: () => const CreateFeedPage()),
    GetPage(name: AppRoutes.feedRequests, page: () => const FeedRequestsPage(feedId: '')),
    GetPage(name: AppRoutes.subscriptions, page: () => const SubscriptionsListPage(userId: '')),
    GetPage(name: AppRoutes.subscribers, page: () => const SubscribersListPage(feedId: '')),
    GetPage(name: AppRoutes.post, page: () => const PostPage()),
    GetPage(name: AppRoutes.report, page: () => const ReportPage(user: U(uid: ''))),
    GetPage(name: AppRoutes.aboutUs, page: () => const AboutUsPage()),
    GetPage(name: AppRoutes.contacts, page: () => const ContactsPage()),
  ];
}
