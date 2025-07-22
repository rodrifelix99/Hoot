import 'package:hoot/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:solar_icons/solar_icons.dart';

import 'last_welcome.dart';

class ContactsPage extends StatefulWidget {
  final bool skipable;
  const ContactsPage({Key? key, this.skipable = false}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late AuthController _authProvider;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool allowed = false;
  bool loading = true;
  List<U> friends = [];
  List<Contact> contacts = [];


  @override
  void initState() {
    _authProvider = Get.find<AuthController>();
    super.initState();
    listContacts(false);
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => const LastWelcomeScreen()
      ),
          (Route<dynamic> route) => false,
    );
  }

  List<Contact> getUninvitedContacts() {
    List<String> invitedPhoneNumbers = friends.map((e) => e.phoneNumber ?? '').toList();
    return contacts.where((element) => !invitedPhoneNumbers.contains(element.phones.first.normalizedNumber)).toList();
  }

  Future<void> listContacts(bool refresher) async {
    setState(() {
      loading = !refresher;
    });
    if (await FlutterContacts.requestPermission()) {
      allowed = true;
      contacts = await FlutterContacts.getContacts(withProperties: true);

      //remove contacts without phone numbers
      contacts.removeWhere((element) => element.phones.isEmpty);
      if (contacts.isEmpty) {
        setState(() {
          _refreshController.refreshCompleted();
          loading = false;
        });
        return;
      }

      List<String> validPhoneNumbers = [];
      for (Contact contact in contacts) {
        for (Phone phone in contact.phones) {
          if (phone.normalizedNumber.isNotEmpty) {
            validPhoneNumbers.add(phone.normalizedNumber);
          } else if (phone.number.isNotEmpty) {
            final String phoneNumber = phone.number.replaceAll(' ', '').replaceAll('-', '');
            validPhoneNumbers.add(phoneNumber);
          }
        }
      }

      friends = await _authProvider.getContacts(validPhoneNumbers);
      setState(() {
        loading = false;
      });
    } else {
      allowed = false;
    }
    setState(() {
      _refreshController.refreshCompleted();
      loading = false;
    });
  }

  String getFormattedName(U user) {
    Contact? contact = contacts.firstWhereOrNull(
            (e) => e.phones.first.normalizedNumber.contains(user.phoneNumber ?? '')
                || e.phones.first.number.contains(user.phoneNumber ?? '')
    );
    if (contact == null) {
      return user.name ?? '@${user.username}';
    } else {
      return "${user.name ?? '@${user.username}'} (${contact.displayName})";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: AppLocalizations.of(context)!.findFriends,
        actions: widget.skipable ? [
          TextButton(
            onPressed: _goHome,
            child: Text(
              AppLocalizations.of(context)!.skip,
            ),
          )
        ] : [],
      ),
      body: SmartRefresher(
        enablePullDown: !loading,
        onRefresh: () async => await listContacts(true),
        controller: _refreshController,
        child: loading ? const Center(
          child: CircularProgressIndicator(),
        ) : !allowed ? NothingToShowComponent(
          icon: const Icon(SolarIconsBold.phoneCallingRounded),
          text: AppLocalizations.of(context)!.contactsPermission,
        ) : friends.isEmpty ? Center(
          child: NothingToShowComponent(
            icon: const Icon(SolarIconsBold.magnifierZoomOut),
            text: AppLocalizations.of(context)!.noResults,
            buttonText: widget.skipable ? AppLocalizations.of(context)!.continueButton : null,
            buttonAction: widget.skipable ? _goHome : null,
          ),
        ) : ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            U contact = friends[index];
            return ListTile(
              onTap: () => Get.toNamed(context, '/profile', arguments: contact),
              leading: Avatar(
                image: contact.smallProfilePictureUrl ?? '',
                size: 40,
                radius: 20,
              ),
              title: Text(getFormattedName(contact)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
            );
          },
        ),
      ),
    );
  }
}
