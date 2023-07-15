import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class FeedRequestsPage extends StatefulWidget {
  final int feedIndex;
  const FeedRequestsPage({super.key, required this.feedIndex});

  @override
  State<FeedRequestsPage> createState() => _FeedRequestsPageState();
}

class _FeedRequestsPageState extends State<FeedRequestsPage> {
  late FeedProvider _feedProvider;
  late AuthProvider _authProvider;
  List<U> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    super.initState();
    _getRequests();
  }

  @override
  void dispose() {
    _feedProvider.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  Future _getRequests() async {
    setState(() => _loading = true);
    List<U> requests = await _feedProvider.getFeedRequests(_authProvider.user!.feeds![widget.feedIndex].id);
    setState(() {
      _requests = requests;
      _loading = false;
    });
  }

  Future _acceptRequest(String uid) async {
    U cachedUser = _requests.firstWhere((element) => element.uid == uid);
    setState(() => _requests.removeWhere((element) => element.uid == uid));
    _authProvider.notify();
    bool res = await _feedProvider.acceptRequest(uid, _authProvider.user!.feeds![widget.feedIndex].id);
    if (!res) {
      setState(() => _requests.add(cachedUser));
      ToastService.showToast(context, 'Error accepting request', true);
    } else {
      setState(() => {
        _authProvider.user!.feeds![widget.feedIndex].requests!.remove(uid),
        _authProvider.user!.feeds![widget.feedIndex].subscribers!.add(uid),
        _authProvider.notify()
      });
    }
  }

  Future _declineRequest(String uid) async {
    U cachedUser = _requests.firstWhere((element) => element.uid == uid);
    setState(() => _requests.removeWhere((element) => element.uid == uid));
    bool res = await _feedProvider.declineRequest(uid, _authProvider.user!.feeds![widget.feedIndex].id);
    if (!res) {
      setState(() => _requests.add(cachedUser));
      ToastService.showToast(context, 'Error declining request', true);
    } else {
      setState(() => {
        _authProvider.user!.feeds![widget.feedIndex].requests!.remove(uid),
        _authProvider.user!.feeds![widget.feedIndex].subscribers!.add(uid)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Subscription requests"),
        ),
        body: _loading ? const Center(child: CircularProgressIndicator()) : _requests.isNotEmpty ? LiquidPullToRefresh(
          onRefresh: _getRequests,
          backgroundColor: Theme.of(context).colorScheme.primary,
          color: Theme.of(context).colorScheme.onPrimary,
          child: ListView.builder(
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: ProfileAvatar(image: _requests[index].smallProfilePictureUrl ?? '', size: 40),
                title: Text(_requests[index].name ?? ''),
                subtitle: Text("@${_requests[index].username ?? ''}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async => await _acceptRequest(_requests[index].uid),
                      icon: const Icon(Icons.check),
                    ),
                    IconButton(
                      onPressed: () async => await _declineRequest(_requests[index].uid),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              );
            },
          ),
        ) : const Center(
          child: NothingToShowComponent(
            icon: Icon(Icons.check_circle_outline_rounded),
            text: 'There are no requests for this feed',
          ),
        )
    );
  }
}
