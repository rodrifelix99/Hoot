import 'package:get/get.dart';
import 'package:hoot/pages/login/bindings/login_binding.dart';
import 'package:hoot/pages/login/views/login_view.dart';
import 'package:hoot/util/routes/app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
