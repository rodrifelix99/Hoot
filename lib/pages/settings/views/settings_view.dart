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
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildSection(
                context,
                title: 'appearance'.tr,
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
                ],
              );
            case 1:
              return _buildSection(
                context,
                title: 'account'.tr,
                children: [
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
                ],
              );
            default:
              return _buildSection(
                context,
                title: 'about'.tr,
                children: [
                  ExpansionTile(
                    title: Text('messageFromCreator'.tr),
                    childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    children: [
                      Text('hootMightBeBuggy'.tr),
                    ],
                  ),
                  Obx(
                    () => ListTile(
                      title: Text('version'.tr),
                      subtitle: Text(controller.version.value),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => children[index],
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: children.length,
        ),
      ],
    );
  }
}
