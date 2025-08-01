import 'package:get/get.dart';
import 'package:hoot/pages/search_by_genre/controllers/search_by_genre_controller.dart';

class SearchByGenreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchByGenreController());
  }
}
