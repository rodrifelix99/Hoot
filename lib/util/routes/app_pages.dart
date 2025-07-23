import 'package:get/get.dart';
import 'package:hoot/pages/login/bindings/login_binding.dart';
import 'package:hoot/pages/login/views/login_view.dart';
import 'package:hoot/pages/welcome/bindings/welcome_binding.dart';
import 'package:hoot/pages/welcome/views/welcome_view.dart';
import 'package:hoot/pages/username/bindings/username_binding.dart';
import 'package:hoot/pages/username/views/username_view.dart';
import 'package:hoot/pages/avatar/bindings/avatar_binding.dart';
import 'package:hoot/pages/avatar/views/avatar_view.dart';
import 'package:hoot/pages/home/bindings/home_binding.dart';
import 'package:hoot/pages/home/views/home_view.dart';
import 'package:hoot/pages/create_post/bindings/create_post_binding.dart';
import 'package:hoot/pages/create_post/views/create_post_view.dart';
import 'package:hoot/pages/profile/bindings/profile_binding.dart';
import 'package:hoot/pages/profile/views/profile_view.dart';
import 'package:hoot/pages/settings/bindings/settings_binding.dart';
import 'package:hoot/pages/settings/views/settings_view.dart';
import 'package:hoot/pages/edit_profile/bindings/edit_profile_binding.dart';
import 'package:hoot/pages/edit_profile/views/edit_profile_view.dart';
import 'package:hoot/pages/search/bindings/search_binding.dart';
import 'package:hoot/pages/search/views/search_view.dart';
import 'package:hoot/pages/search_by_genre/bindings/search_by_genre_binding.dart';
import 'package:hoot/pages/search_by_genre/views/search_by_genre_view.dart';
import 'package:hoot/pages/create_feed/bindings/create_feed_binding.dart';
import 'package:hoot/pages/create_feed/views/create_feed_view.dart';
import 'package:hoot/pages/edit_feed/bindings/edit_feed_binding.dart';
import 'package:hoot/pages/edit_feed/views/edit_feed_view.dart';
import 'package:hoot/pages/feed_requests/bindings/feed_requests_binding.dart';
import 'package:hoot/pages/feed_requests/views/feed_requests_view.dart';
import 'package:hoot/pages/subscriptions/bindings/subscriptions_binding.dart';
import 'package:hoot/pages/subscriptions/views/subscriptions_view.dart';
import 'package:hoot/pages/subscribers/bindings/subscribers_binding.dart';
import 'package:hoot/pages/subscribers/views/subscribers_view.dart';
import 'package:hoot/pages/post/bindings/post_binding.dart';
import 'package:hoot/pages/post/views/post_view.dart';
import 'package:hoot/pages/report/bindings/report_binding.dart';
import 'package:hoot/pages/report/views/report_view.dart';
import 'package:hoot/pages/contacts/bindings/contacts_binding.dart';
import 'package:hoot/pages/contacts/views/contacts_view.dart';
import 'package:hoot/pages/terms.dart';
import 'package:hoot/pages/about_us.dart';
import 'package:hoot/util/routes/app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: AppRoutes.username,
      page: () => const UsernameView(),
      binding: UsernameBinding(),
    ),
    GetPage(
      name: AppRoutes.avatar,
      page: () => const AvatarView(),
      binding: AvatarBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.createPost,
      page: () => const CreatePostView(),
      binding: CreatePostBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.searchByGenre,
      page: () => const SearchByGenreView(),
      binding: SearchByGenreBinding(),
    ),
    GetPage(
      name: AppRoutes.createFeed,
      page: () => const CreateFeedView(),
      binding: CreateFeedBinding(),
    ),
    GetPage(
      name: AppRoutes.editFeed,
      page: () => const EditFeedView(),
      binding: EditFeedBinding(),
    ),
    GetPage(
      name: AppRoutes.feedRequests,
      page: () => const FeedRequestsView(),
      binding: FeedRequestsBinding(),
    ),
    GetPage(
      name: AppRoutes.subscriptions,
      page: () => const SubscriptionsView(),
      binding: SubscriptionsBinding(),
    ),
    GetPage(
      name: AppRoutes.subscribers,
      page: () => const SubscribersView(),
      binding: SubscribersBinding(),
    ),
    GetPage(
      name: AppRoutes.post,
      page: () => const PostView(),
      binding: PostBinding(),
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportView(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.terms,
      page: () => const TermsOfService(),
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsPage(),
    ),
    GetPage(
      name: AppRoutes.contacts,
      page: () => const ContactsView(),
      binding: ContactsBinding(),
    ),
  ];
}
