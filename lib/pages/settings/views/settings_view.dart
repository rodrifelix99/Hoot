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
            leading: const Icon(Icons.palette_outlined),
            title: Text('appColor'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(AppRoutes.appColor),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('editProfile'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.goToEditProfile,
          ),
          ListTile(
            title: Text('findFriends'.tr),
            subtitle: Text('findFriendsFromContacts'.tr),
            onTap: controller.findFriends,
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions_outlined),
            title: Text('subscriptions'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(AppRoutes.subscriptions),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text('termsOfService'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(AppRoutes.terms),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text('deleteAccount'.tr),
            subtitle: Text('deleteAccountDescription'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => controller.deleteAccount(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: Text('signOut'.tr),
            trailing: const Icon(Icons.chevron_right),
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
