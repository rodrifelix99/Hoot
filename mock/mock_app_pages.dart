import 'package:get/get.dart';
import 'package:hoot/pages/login/bindings/login_binding.dart';
import 'package:hoot/pages/login/views/login_view.dart';
import 'package:hoot/pages/photo_view/bindings/photo_view_binding.dart';
import 'package:hoot/pages/photo_view/views/photo_view.dart';
import 'package:hoot/pages/welcome/bindings/welcome_binding.dart';
import 'package:hoot/pages/welcome/views/welcome_view.dart';
import 'package:hoot/pages/username/bindings/username_binding.dart';
import 'package:hoot/pages/avatar/bindings/avatar_binding.dart';
import 'package:hoot/pages/home/bindings/home_binding.dart';
import 'package:hoot/pages/home/views/home_view.dart';
import 'package:hoot/pages/invitation/bindings/invitation_binding.dart';
import 'package:hoot/pages/invitation/views/invitation_view.dart';
import 'package:hoot/pages/notifications_permission/bindings/notification_permission_binding.dart';
import 'package:hoot/pages/notifications_permission/views/notification_permission_view.dart';
import 'package:hoot/pages/create_post/bindings/create_post_binding.dart';
import 'package:hoot/pages/create_post/views/create_post_view.dart';
import 'package:hoot/pages/profile/bindings/profile_binding.dart';
import 'package:hoot/pages/profile/views/profile_view.dart';
import 'package:hoot/pages/settings/bindings/settings_binding.dart';
import 'package:hoot/pages/settings/views/settings_view.dart';
import 'package:hoot/pages/app_color/bindings/app_color_binding.dart';
import 'package:hoot/pages/app_color/views/app_color_view.dart';
import 'package:hoot/pages/edit_profile/bindings/edit_profile_binding.dart';
import 'package:hoot/pages/edit_profile/views/edit_profile_view.dart';
import 'package:hoot/pages/search/bindings/search_binding.dart';
import 'package:hoot/pages/search/views/search_view.dart';
import 'package:hoot/pages/search_by_genre/bindings/search_by_genre_binding.dart';
import 'package:hoot/pages/search_by_genre/views/search_by_genre_view.dart';
import 'package:hoot/pages/feed_editor/bindings/feed_editor_binding.dart';
import 'package:hoot/pages/feed_editor/views/feed_editor_view.dart';
import 'package:hoot/pages/feed_requests/bindings/feed_requests_binding.dart';
import 'package:hoot/pages/feed_requests/views/feed_requests_view.dart';
import 'package:hoot/pages/subscriptions/bindings/subscriptions_binding.dart';
import 'package:hoot/pages/subscriptions/views/subscriptions_view.dart';
import 'package:hoot/pages/subscribers/bindings/subscribers_binding.dart';
import 'package:hoot/pages/subscribers/views/subscribers_view.dart';
import 'package:hoot/pages/feed_page/bindings/feed_page_binding.dart';
import 'package:hoot/pages/feed_page/views/feed_page_view.dart';
import 'package:hoot/pages/post/bindings/post_binding.dart';
import 'package:hoot/pages/post/views/post_view.dart';
import 'package:hoot/pages/report/bindings/report_binding.dart';
import 'package:hoot/pages/report/views/report_view.dart';
import 'package:hoot/pages/contacts/bindings/contacts_binding.dart';
import 'package:hoot/pages/contacts/views/contacts_view.dart';
import 'package:hoot/pages/terms.dart';
import 'package:hoot/pages/about_us.dart';
import 'package:hoot/util/constants.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';

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
        binding: WelcomeBinding()),
    GetPage(
        name: AppRoutes.username,
        page: () => const WelcomeView(initialIndex: kWelcomeUsernameStep),
        binding: UsernameBinding()),
    GetPage(
        name: AppRoutes.avatar,
        page: () => const WelcomeView(initialIndex: kWelcomeAvatarStep),
        binding: AvatarBinding()),
    GetPage(
        name: AppRoutes.invitation,
        page: () => const InvitationView(),
        binding: InvitationBinding()),
    GetPage(
        name: AppRoutes.notificationsPermission,
        page: () => const NotificationPermissionView(),
        binding: NotificationPermissionBinding()),
    GetPage(
        name: AppRoutes.home,
        page: () => const HomeView(),
        binding: HomeBinding()),
    GetPage(
        name: AppRoutes.createPost,
        page: () => const CreatePostView(),
        binding: CreatePostBinding()),
    GetPage(
        name: AppRoutes.settings,
        page: () => const SettingsView(),
        binding: SettingsBinding()),
    GetPage(
        name: AppRoutes.appColor,
        page: () => const AppColorView(),
        binding: AppColorBinding()),
    GetPage<ProfileArgs>(
        name: AppRoutes.profile,
        page: () => const ProfileView(),
        binding: ProfileBinding()),
    GetPage(
        name: AppRoutes.editProfile,
        page: () => const EditProfileView(),
        binding: EditProfileBinding()),
    GetPage(
        name: AppRoutes.search,
        page: () => const SearchView(),
        binding: SearchBinding()),
    GetPage(
        name: AppRoutes.searchByGenre,
        page: () => const SearchByGenreView(),
        binding: SearchByGenreBinding()),
    GetPage(
        name: AppRoutes.createFeed,
        page: () => const FeedEditorView(),
        binding: FeedEditorBinding()),
    GetPage(
        name: AppRoutes.editFeed,
        page: () => const FeedEditorView(),
        binding: FeedEditorBinding()),
    GetPage(
        name: AppRoutes.feedRequests,
        page: () => const FeedRequestsView(),
        binding: FeedRequestsBinding()),
    GetPage(
        name: AppRoutes.subscriptions,
        page: () => const SubscriptionsView(),
        binding: SubscriptionsBinding()),
    GetPage(
        name: AppRoutes.subscribers,
        page: () => const SubscribersView(),
        binding: SubscribersBinding()),
    GetPage<FeedPageArgs>(
        name: AppRoutes.feed,
        page: () => const FeedPageView(),
        binding: FeedPageBinding()),
    GetPage(
        name: AppRoutes.post,
        page: () => const PostView(),
        binding: PostBinding()),
    GetPage(
        name: AppRoutes.report,
        page: () => const ReportView(),
        binding: ReportBinding()),
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
        binding: ContactsBinding()),
    GetPage(
        name: AppRoutes.photoViewer,
        page: () => const PhotoZoomView(),
        binding: PhotoViewBinding()),
  ];
}
