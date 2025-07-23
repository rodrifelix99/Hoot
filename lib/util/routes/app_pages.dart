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
  ];
}
