import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtension on DateTime {
  String timeAgo() {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    return timeago.format(this, locale: locale);
  }
}
