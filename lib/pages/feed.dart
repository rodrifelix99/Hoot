import 'package:flutter/material.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/user_suggestions.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/post_component.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late FeedProvider _feedProvider;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isLoading = false;

  Future _getPosts(DateTime startAfter, { bool refresh = false }) async {
    try {
      !refresh ? setState(() => _isLoading = true) : null;
      await _feedProvider.getMainFeed(startAfter, refresh);
    } catch (e) {
      print(e);
      ToastService.showToast(context, e.toString(), true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    super.initState();
    _feedProvider.mainFeedPosts.isEmpty ? _getPosts(DateTime.now()) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myFeeds),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.search),
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: _feedProvider.mainFeedPosts.isNotEmpty,
        header: const WaterDropHeader(),
        onRefresh: () async {
          await _getPosts(DateTime.now(), refresh: false);
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await _getPosts(_feedProvider.mainFeedPosts.last.createdAt ?? DateTime.now(), refresh: false);
          _refreshController.loadComplete();
        },
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const UserSuggestions(),
                const Divider(),
                _feedProvider.mainFeedPosts.isNotEmpty ? Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _feedProvider.mainFeedPosts.length,
                    itemBuilder: (context, index) {
                      return PostComponent(post: _feedProvider.mainFeedPosts[index]);
                    },
                  ),
                ) : const Center(
                  child: NothingToShowComponent(
                    icon: Icon(Icons.newspaper_rounded),
                    text: 'No hoots to show\nSubscribe to some feeds to see hoots here',
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}
