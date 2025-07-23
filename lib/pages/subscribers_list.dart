import 'package:hoot/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../app/utils/logger.dart';

class SubscribersListPage extends StatefulWidget {
  final String feedId;
  const SubscribersListPage({super.key, required this.feedId});

  @override
  State<SubscribersListPage> createState() => _SubscribersListPageState();
}

class _SubscribersListPageState extends State<SubscribersListPage> {
  late FeedController _feedProvider;
  List<U> _subscriptions = [];
  bool _loading = true;

  @override
  void initState() {
    _feedProvider = Get.find<FeedController>();
    super.initState();
    _getSubscriptions();
  }

  Future _getSubscriptions() async {
    try {
      setState(() {
        _loading = true;
      });
      List<U> subscriptions = await _feedProvider.getSubscribers(widget.feedId);
      setState(() {
        _subscriptions = subscriptions;
      });
    } catch (e) {
      logError(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          title: _subscriptions.isEmpty
              ? AppLocalizations.of(context)!.subscriptions
              : AppLocalizations.of(context)!
                  .numberOfSubscribers(_subscriptions.length),
        ),
        body: _loading
            ? Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 50,
                ),
              )
            : _subscriptions.isEmpty
                ? const Center(
                    child: NothingToShowComponent(
                      icon: Icon(Icons.article_rounded),
                      text: "No subscriptions found",
                    ),
                  )
                : ListView.builder(
                    itemCount: _subscriptions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () => Get.toNamed(context, '/profile',
                            arguments: _subscriptions[index]),
                        leading: ProfileAvatarComponent(
                          image: _subscriptions[index].smallProfilePictureUrl ??
                              '',
                          size: 40,
                        ),
                        title: Text(_subscriptions[index].name ?? ''),
                        subtitle:
                            Text("@${_subscriptions[index].username ?? ''}"),
                      );
                    },
                  ));
  }
}
