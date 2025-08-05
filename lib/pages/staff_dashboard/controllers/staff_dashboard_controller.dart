import 'package:get/get.dart';
import 'package:hoot/services/stats_service.dart';

class StaffDashboardController extends GetxController {
  final StatsService _service = Get.isRegistered<StatsService>()
      ? Get.find<StatsService>()
      : StatsService();

  StaffDashboardController();

  /// Aggregated statistics including feedback counts.
  final Rx<Stats?> stats = Rx<Stats?>(null);
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    loading.value = true;
    try {
      stats.value = await _service.fetchStats();
    } finally {
      loading.value = false;
    }
  }
}
