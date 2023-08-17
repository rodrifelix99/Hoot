import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/feed.dart';

class SubscriptionsListPage extends StatefulWidget {
  final String userId;
  const SubscriptionsListPage({super.key, required this.userId});

  @override
  State<SubscriptionsListPage> createState() => _SubscriptionsListPageState();
}

class _SubscriptionsListPageState extends State<SubscriptionsListPage> {
  late FeedProvider _feedProvider;
  late AuthProvider _authProvider;
  List<Feed> _subscriptions = [];
  bool _loading = true;

  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    _getSubscriptions();
  }

  Future _getSubscriptions() async {
    try {
      setState(() {
        _loading = true;
      });
      List<Feed> subscriptions = await _feedProvider.getSubscriptions(widget.userId);
      setState(() {
        _subscriptions = subscriptions;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future _unsubscribe(String userId, String feedId) async {
    try {
      Feed cachedFeed = _subscriptions.firstWhere((element) => element.id == feedId);
      setState(() => _subscriptions.remove(cachedFeed));
      bool res = await _feedProvider.unsubscribeFromFeed(userId, feedId);
      if (!res) {
        setState(() {
          _subscriptions.add(cachedFeed);
          ToastService.showToast(context, "Something went wrong", true);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  bool _isAuthor(String userId) => _authProvider.user?.uid == userId;
  bool _isUser() => _authProvider.user?.uid == widget.userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.subscriptions),
      ),
      body: _loading ? Center(
        child: LoadingAnimationWidget.inkDrop(
            color: Theme.of(context).colorScheme.onSurface,
            size: 50,
        ),
      ) : _subscriptions.isEmpty ? Center(
        child: NothingToShowComponent(
          icon: Icon(Icons.article_rounded),
          text: "No subscriptions found",
        ),
      ) : ListView.builder(
        itemCount: _subscriptions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () => Navigator.pushNamed(context, '/profile', arguments: _subscriptions[index].user),
            leading: ProfileAvatarComponent(
              image: _subscriptions[index].user?.smallProfilePictureUrl ?? '',
              size: 40,
            ),
            title: Text(_subscriptions[index].title),
            subtitle: Text(_subscriptions[index].description ?? ''),
            trailing: !_isAuthor(_subscriptions[index].user!.uid) && _isUser() ? IconButton(
              icon: const LineIcon(LineIcons.minusCircle, color: Colors.red, size: 30),
              onPressed: () => _unsubscribe(_subscriptions[index].user!.uid, _subscriptions[index].id),
            ) : null,
          );
        },
      )
    );
  }
}
