import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_by_genre_controller.dart';

class SearchByGenreView extends GetView<SearchByGenreController> {
  const SearchByGenreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('searchByGenre'.tr),
      ),
      body: Center(
        child: Text('searchByGenre'.tr),
      ),
    );
  }
}
