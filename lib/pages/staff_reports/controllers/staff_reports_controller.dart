import 'package:get/get.dart';
import 'package:hoot/models/report.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/report_service.dart';

class StaffReportsController extends GetxController {
  final BaseReportService _service;
  final BasePostService _postService;

  StaffReportsController(
      {BaseReportService? service, BasePostService? postService})
      : _service = service ??
            (Get.isRegistered<BaseReportService>()
                ? Get.find<BaseReportService>()
                : ReportService()),
        _postService = postService ??
            (Get.isRegistered<BasePostService>()
                ? Get.find<BasePostService>()
                : PostService());

  final RxList<Report> reports = <Report>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    loading.value = true;
    try {
      final result = await _service.fetchReports();
      reports.assignAll(result);
    } finally {
      loading.value = false;
    }
  }

  Future<void> dismiss(String reportId) async {
    await _service.resolveReport(reportId, action: 'dismiss');
    reports.removeWhere((r) => r.id == reportId);
  }

  Future<void> removePost(Report report) async {
    await _postService.deletePost(report.targetId);
    await _service.resolveReport(report.id, action: 'remove_post');
    reports.removeWhere((r) => r.id == report.id);
  }

  Future<void> warnUser(Report report) async {
    await _service.resolveReport(report.id, action: 'warn_user');
    reports.removeWhere((r) => r.id == report.id);
  }
}
