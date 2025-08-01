import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/pages/settings/controllers/settings_controller.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/util/routes/app_routes.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'settings'.tr,
      ),
      body: ListView(
        children: [
          Obx(
            () => ListTile(
              title: Text('darkMode'.tr),
              trailing: DropdownButton<ThemeMode>(
                key: const Key('themeModeDropdown'),
                value: controller.themeMode,
                onChanged: controller.updateThemeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('syncedWithSystem'.tr),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('light'.tr),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('dark'.tr),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text('appColor'.tr),
            onTap: () => Get.toNamed(AppRoutes.appColor),
          ),
          ListTile(
            title: Text('editProfile'.tr),
            onTap: controller.goToEditProfile,
          ),
          ListTile(
            title: Text('findFriends'.tr),
            subtitle: Text('findFriendsFromContacts'.tr),
            onTap: controller.findFriends,
          ),
          ListTile(
            title: Text('subscriptions'.tr),
            onTap: () => Get.toNamed(AppRoutes.subscriptions),
          ),
          ListTile(
            title: Text('termsOfService'.tr),
            onTap: () => Get.toNamed(AppRoutes.terms),
          ),
          ListTile(
            title: Text('deleteAccount'.tr),
            subtitle: Text('deleteAccountDescription'.tr),
            onTap: () => controller.deleteAccount(context),
          ),
          ListTile(
            title: Text('signOut'.tr),
            onTap: () => controller.signOut(context),
          ),
          const Divider(),
          ExpansionTile(
            title: Text('messageFromCreator'.tr),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              Text('hootMightBeBuggy'.tr),
            ],
          ),
          Obx(() => ListTile(
                title: Text('version'.tr),
                subtitle: Text(controller.version.value),
              )),
        ],
      ),
    );
  }
}
