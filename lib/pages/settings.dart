import 'package:flutter/material.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/services/error_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AuthController _authProvider;
  bool _loading = false;
  String _version = "";

  @override
  void initState() {
    _authProvider = Get.find<AuthController>();
    _loadVersion();
    super.initState();
  }

  Future _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${packageInfo.version} (${packageInfo.buildNumber})";
    });
  }

  Future _signOut() async {
    // show confirmation dialog
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('signOut'.tr),
        content: Text('signOutConfirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('signOut'.tr),
          ),
        ],
      ),
    );
    if (result == true) {
      await _authProvider.signOut();
      Get.offAllNamed('/login', predicate: (route) => false);
    }
  }

  Future _deleteAccount() async {
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteAccountConfirmation'.tr),
        content: Text('deleteAccountDescription'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('deleteAccount'.tr),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      setState(() {
        _loading = true;
      });
      bool res = await _authProvider.deleteAccount();
      if (res) {
        ToastService.showToast(context, 'deleteAccountSuccess'.tr, false);
        Get.offAllNamed('/login', predicate: (route) => false);
      } else {
        setState(() {
          _loading = false;
          ToastService.showToast(context, 'deleteAccountFailed'.tr, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              Get.offAllNamed('/home', predicate: (route) => false),
        ),
        title: Text('settings'.tr),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                    child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(SolarIconsBold.moonFog),
                        title: Text('darkMode'.tr),
                        subtitle: Text('syncedWithSystem'.tr),
                        trailing: Switch(
                          value:
                              Theme.of(context).brightness == Brightness.dark,
                          onChanged: (value) {},
                        ),
                      ),
                      ListTile(
                        leading: const Icon(SolarIconsBold.userRounded),
                        title: Text('editProfile'.tr),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Get.toNamed('/edit_profile'),
                      ),
                      ListTile(
                        leading: const Icon(SolarIconsBold.phoneRounded),
                        title: Text('findFriends'.tr),
                        subtitle: Text('findFriendsFromContacts'.tr),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Get.toNamed('/contacts'),
                      ),
                      ListTile(
                        leading: const Icon(SolarIconsBold.shieldCheck),
                        title: Text('termsOfService'.tr),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Get.toNamed('/terms_of_service'),
                      ),
                      /*ListTile(
                      leading: const Icon(SolarIconsBold.verifiedCheck),
                      title: Text('aboutUs'.tr),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/about_us'),
                    ),*/
                      ListTile(
                        leading:
                            const Icon(SolarIconsBold.trashBinMinimalistic),
                        title: Text('deleteAccount'.tr),
                        onTap: _deleteAccount,
                      ),
                      ListTile(
                        title: Text('version'.tr),
                        subtitle: Text(_version),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text('messageFromCreator'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('hootMightBeBuggy'.tr),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('- Felix',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/felix.jpg',
                            width: MediaQuery.of(context).size.width - 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                )),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.9),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: _signOut,
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style!
                              .copyWith(
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(Colors.red),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white),
                              ),
                          child: Text('signOut'.tr),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
