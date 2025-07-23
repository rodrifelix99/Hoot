import 'package:get/get.dart';
import 'package:hoot/pages/login.dart';
import 'package:hoot/pages/welcome.dart';
import 'package:hoot/pages/username.dart';
import 'package:hoot/pages/avatar.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
    GetPage(name: AppRoutes.username, page: () => const UsernamePage()),
    GetPage(name: AppRoutes.avatar, page: () => const AvatarPage()),
  ];
}
