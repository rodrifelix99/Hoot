import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/models/user.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/error_service.dart';

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
      List<U> res = await Provider.of<AuthProvider>(context, listen: false).searchUsers(_searchController.text);
      setState(() {
        _users = res;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        ToastService.showToast(context, e.toString(), true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.search)),
      body:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onEditingComplete: () => _search(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchPlaceholder,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _search(),
                  ),
                ),
              ),
            ),
            _isLoading ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            )) : Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: ProfileAvatar(
                      image: _users[index].smallProfilePictureUrl ?? '',
                      size: 40,
                    ),
                    title: Text(_users[index].name ?? ''),
                    subtitle: Text("@${_users[index].username}"),
                    onTap: () => Navigator.of(context).pushNamed('/profile', arguments: _users[index]),
                  );
                },
              ),
            ),
          ],
      ),
    );
  }
}
