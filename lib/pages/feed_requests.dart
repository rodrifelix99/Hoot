import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:hoot/models/user.dart';

class FeedRequestsPage extends StatefulWidget {
  final String feedId;
  const FeedRequestsPage({super.key, required this.feedId});

  @override
  State<FeedRequestsPage> createState() => _FeedRequestsPageState();
}

class _FeedRequestsPageState extends State<FeedRequestsPage> {
  late FeedController _feedProvider;
  late AuthController _authProvider;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<U> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    _authProvider = Get.find<AuthController>();
    _feedProvider = Get.find<FeedController>();
    super.initState();
    _getRequests();
  }

  Future _getRequests() async {
    setState(() => _loading = true);
    List<U> requests = await _feedProvider.getFeedRequests(widget.feedId);
    setState(() {
      _refreshController.refreshCompleted();
      _requests = requests;
      _loading = false;
    });
  }

  Future _acceptRequest(String uid) async {
    U cachedUser = _requests.firstWhere((element) => element.uid == uid);
    setState(() => _requests.removeWhere((element) => element.uid == uid));
    bool res = await _feedProvider.acceptRequest(uid, widget.feedId);
    if (!res) {
      setState(() => _requests.add(cachedUser));
      ToastService.showToast(context, 'Error accepting request', true);
    } else {
      int feedIndex = _authProvider.user!.feeds!.indexWhere((element) => element.id == widget.feedId);
      setState(() {
        _authProvider.user!.feeds![feedIndex].requests!.remove(uid);
        _authProvider.user!.feeds![feedIndex].subscribers!.add(uid);
      });
    }
  }

  Future _declineRequest(String uid) async {
    U cachedUser = _requests.firstWhere((element) => element.uid == uid);
    setState(() => _requests.removeWhere((element) => element.uid == uid));
    bool res = await _feedProvider.declineRequest(uid, widget.feedId);
    if (!res) {
      setState(() => _requests.add(cachedUser));
      ToastService.showToast(context, 'Error declining request', true);
    } else {
      int feedIndex = _authProvider.user!.feeds!.indexWhere((element) => element.id == widget.feedId);
      setState(() {
        _authProvider.user!.feeds![feedIndex].requests!.remove(uid);
        _authProvider.user!.feeds![feedIndex].subscribers!.add(uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Subscription requests"),
        ),
        body: _loading ? const Center(child: CircularProgressIndicator()) : _requests.isNotEmpty ? SmartRefresher(
          controller: _refreshController,
          onRefresh: _getRequests,
          child: ListView.builder(
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: ProfileAvatarComponent(image: _requests[index].smallProfilePictureUrl ?? '', size: 40),
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
