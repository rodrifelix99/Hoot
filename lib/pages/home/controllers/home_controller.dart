import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../util/routes/app_routes.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _verifyUser();
  }

  Future<void> _verifyUser() async {
    final user = await _auth.fetchUser();
    if (user == null) {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
