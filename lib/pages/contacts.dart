import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import 'last_welcome.dart';

class ContactsPage extends StatefulWidget {
  final bool skipable;
  const ContactsPage({Key? key, this.skipable = false}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late AuthProvider _authProvider;
  bool allowed = false;
  bool loading = true;
  List<U> friends = [];
  List<Contact> contacts = [];


  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    listContacts();
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

  Future<void> listContacts() async {
    setState(() {
      loading = true;
    });
    if (await FlutterContacts.requestPermission()) {
      allowed = true;
      contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      List<String> phoneNumbers = contacts.map((e) => e.phones.first.normalizedNumber).toList();
      friends = await _authProvider.getContacts(phoneNumbers);
    } else {
      allowed = false;
    }
    setState(() {
      loading = false;
    });
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
        body: loading ? const Center(
          child: CircularProgressIndicator(),
        ) : !allowed ? NothingToShowComponent(
            icon: const Icon(SolarIconsBold.phoneCallingRounded),
            text: AppLocalizations.of(context)!.contactsPermission,
        ) : friends.isEmpty ? Center(
          child: NothingToShowComponent(
              icon: const Icon(SolarIconsBold.wind),
              text: AppLocalizations.of(context)!.noResults,
              buttonText: widget.skipable ? AppLocalizations.of(context)!.continueButton : null,
              buttonAction: widget.skipable ? _goHome : null,
          ),
        ) : ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            U contact = friends[index];
            return ListTile(
              onTap: () => Navigator.pushNamed(context, '/profile', arguments: contact),
              leading: Avatar(
                image: contact.smallProfilePictureUrl ?? '',
                size: 40,
                radius: 20,
              ),
              title: Text("${contact.name ?? '@${contact.username}'} (${contacts.firstWhere((element) => element.phones.first.normalizedNumber == contact.phoneNumber).displayName})"),
              subtitle: Text(contacts.firstWhere((element) => element.phones.first.normalizedNumber == contact.phoneNumber).phones.first.number),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
            );
          },
        )
    );
  }
}
