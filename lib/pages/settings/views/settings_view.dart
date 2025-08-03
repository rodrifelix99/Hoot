import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/pages/settings/controllers/settings_controller.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'settings'.tr,
      ),
      extendBodyBehindAppBar: true,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 3,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return SafeArea(
                bottom: false,
                child: _buildSection(
                  context,
                  title: 'appearance'.tr,
                  children: [
                    Obx(
                      () => ListTile(
                        leading: Icon(SolarIconsOutline.moonStars),
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
                      leading: const Icon(SolarIconsOutline.palette2),
                      title: Text('appColor'.tr),
                      trailing: const Icon(SolarIconsOutline.arrowRight),
                      onTap: () => Get.toNamed(AppRoutes.appColor),
                    ),
                  ],
                ),
              );
            case 1:
              return _buildSection(
                context,
                title: 'account'.tr,
                children: [
                  ListTile(
                    leading: const Icon(SolarIconsOutline.user),
                    title: Text('editProfile'.tr),
                    trailing: const Icon(SolarIconsOutline.arrowRight),
                    onTap: controller.goToEditProfile,
                  ),
                  ListTile(
                    leading: const Icon(SolarIconsOutline.usersGroupRounded),
                    title: Text('findFriends'.tr),
                    subtitle: Text('findFriendsFromContacts'.tr),
                    trailing: const Icon(SolarIconsOutline.arrowRight),
                    onTap: controller.findFriends,
                  ),
                  Obx(() {
                    if (controller.isStaff) {
                      return ListTile(
                        leading: const Icon(SolarIconsOutline.shieldUser),
                        title: Text('staff'.tr),
                        trailing: const Icon(SolarIconsOutline.arrowRight),
                        onTap: () => Get.toNamed(AppRoutes.staff),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  ListTile(
                    leading: const Icon(SolarIconsOutline.documents),
                    title: Text('termsOfService'.tr),
                    trailing: const Icon(SolarIconsOutline.arrowRight),
                    onTap: () => Get.toNamed(AppRoutes.terms),
                  ),
                  ListTile(
                    leading: const Icon(SolarIconsOutline.trashBin2),
                    title: Text('deleteAccount'.tr),
                    subtitle: Text('deleteAccountDescription'.tr),
                    trailing: const Icon(SolarIconsOutline.arrowRight),
                    onTap: () => controller.deleteAccount(context),
                  ),
                  ListTile(
                    leading: const Icon(SolarIconsOutline.logout),
                    title: Text('signOut'.tr),
                    trailing: const Icon(SolarIconsOutline.arrowRight),
                    onTap: () => controller.signOut(context),
                  ),
                ],
              );
            default:
              return SafeArea(
                top: false,
                child: _buildSection(
                  context,
                  title: 'about'.tr,
                  children: [
                    ExpansionTile(
                      leading: const Icon(SolarIconsOutline.heartAngle),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      title: Text('messageFromCreator'.tr),
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      children: [
                        Text(
                          'hootMightBeBuggy'.tr,
                          textAlign: TextAlign.justify,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/felix.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => ListTile(
                        leading: const Icon(SolarIconsOutline.infoSquare),
                        title: Text('version'.tr),
                        subtitle: Text(controller.version.value),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    // Filter out SizedBox.shrink widgets before building the section
    final filteredChildren = children.where((child) => child is! SizedBox || (child as SizedBox).height != 0 || (child as SizedBox).width != 0 ).toList();
    if (filteredChildren.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        ListView.separated(
          padding: EdgeInsets.only(
            bottom: 32,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => filteredChildren[index],
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: filteredChildren.length,
        ),
      ],
    );
  }
}