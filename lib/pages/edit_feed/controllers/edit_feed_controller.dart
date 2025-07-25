import 'package:get/get.dart';

import '../../../models/feed.dart';

class EditFeedController extends GetxController {
  late Feed feed;

  @override
  void onInit() {
    super.onInit();
    feed = Get.arguments as Feed;
  }
}
