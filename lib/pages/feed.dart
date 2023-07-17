import 'package:flutter/material.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/post_component.dart';
import '../models/post.dart';

class FeedPage extends StatefulWidget {
  final VoidCallback toggleRadio;
  const FeedPage({super.key, required this.toggleRadio});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late FeedProvider _feedProvider;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isLoading = false;

  Future _getPosts(DateTime startAfter, { bool refresh = false }) async {
    try {
      if (_feedProvider.mainFeedPosts.isEmpty && !refresh) {
        setState(() => _isLoading = true);
      }
      await _feedProvider.getMainFeed(startAfter, refresh);
    } catch (e) {
      print(e);
      ToastService.showToast(context, e.toString(), true);
    } finally {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
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
            icon: const LineIcon(LineIcons.search),
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
          IconButton(
              onPressed: widget.toggleRadio,
              icon: const LineIcon(LineIcons.music)
          )
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SmartRefresher(
        controller: _refreshController,
        enablePullUp: _feedProvider.mainFeedPosts.isNotEmpty,
        header: const ClassicHeader(
          refreshingText: '',
          idleText: '',
          completeText: '',
          releaseText: '',
        ),
        footer: const ClassicFooter(
          failedText: '',
          idleText: '',
          loadingText: '',
          noDataText: '',
          canLoadingText: '',
        ),
        onRefresh: () async =>  await _getPosts(DateTime.now(), refresh: true),
        onLoading: () async => await _getPosts(_feedProvider.mainFeedPosts.last.createdAt ?? DateTime.now(), refresh: false),
        child: _feedProvider.mainFeedPosts.isNotEmpty ? ListView.builder(
            itemCount: _feedProvider.mainFeedPosts.length,
            itemBuilder: (context, index) {
              Post post = _feedProvider.mainFeedPosts[index];
              return PostComponent(post: post);
            }
        ) : Center(
          child: NothingToShowComponent(
            icon: const Icon(Icons.newspaper_rounded),
            text: '${AppLocalizations.of(context)!.noHoots}\n${AppLocalizations.of(context)!.subscribeToSeeHoots}}',
          ),
        ),
      ),
    );
  }
}
