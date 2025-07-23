import 'package:get/get.dart';
import '../controllers/search_by_genre_controller.dart';

class SearchByGenreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchByGenreController());
  }
}
