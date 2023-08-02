import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AuthProvider _authProvider;
  bool _loading = false;
  String _version = "";

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
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
        title: Text(AppLocalizations.of(context)!.signOut),
        content: Text(AppLocalizations.of(context)!.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.signOut),
          ),
        ],
      ),
    );
    if (result == true) {
      await _authProvider.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future _deleteAccount() async {
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccountConfirmation),
        content: Text(AppLocalizations.of(context)!.deleteAccountDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.deleteAccount),
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
        ToastService.showToast(context, AppLocalizations.of(context)!.deleteAccountSuccess, false);
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        setState(() {
          _loading = false;
          ToastService.showToast(context, AppLocalizations.of(context)!.deleteAccountFailed, true);
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
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
        ),
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_4_rounded),
                    title: Text(AppLocalizations.of(context)!.darkMode),
                    subtitle: Text(AppLocalizations.of(context)!.syncedWithSystem),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (value) {},
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_rounded),
                    title: Text(AppLocalizations.of(context)!.editProfile),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/edit_profile'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_rounded),
                    title: Text(AppLocalizations.of(context)!.termsOfService),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/terms_of_service'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_rounded),
                    title: Text(AppLocalizations.of(context)!.aboutUs),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/about_us'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_rounded),
                    title: Text(AppLocalizations.of(context)!.deleteAccount),
                    onTap: _deleteAccount,
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.version),
                    subtitle: Text(_version),
                  ),
                ],
              )
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text(AppLocalizations.of(context)!.signOut),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
