import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:hoot/pages/search/controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('search'.tr),
      ),
      body: Center(
        child: Text('search'.tr),
      ),
    );
  }
}
