import 'package:get/get.dart';
import 'package:hoot/pages/login.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
  ];
}
