import 'package:hoot/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/models/user.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/services/error_service.dart';
import '../app/utils/logger.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<U> _users = [];
  bool _isLoading = false;

  Future _search() async {
    try {
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);
      List<U> res =
          await Get.find<AuthController>().searchUsers(_searchController.text);
      setState(() {
        _users = res;
        _isLoading = false;
      });
    } catch (e) {
      logError(e);
      setState(() {
        _isLoading = false;
        ToastService.showToast(context, e.toString(), true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'search'.tr),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onEditingComplete: () => _search(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'searchPlaceholder'.tr,
                suffixIcon: IconButton(
                  icon: const Icon(SolarIconsOutline.magnifier),
                  onPressed: () => _search(),
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(),
                ))
              : _users.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: ProfileAvatarComponent(
                              image: _users[index].smallProfilePictureUrl ?? '',
                              size: 40,
                            ),
                            title: Text(_users[index].name ?? ''),
                            subtitle: Text("@${_users[index].username}"),
                            onTap: () => Get.toNamed('/profile',
                                arguments: _users[index]),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: NothingToShowComponent(
                      icon: const Icon(SolarIconsBold.magnifierZoomOut),
                      text: 'noUsersToShow'.tr,
                    ))
        ],
      ),
    );
  }
}
