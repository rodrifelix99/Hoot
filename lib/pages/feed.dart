import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/native_ad_component.dart';
import 'package:hoot/pages/post.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
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

  String _timeUntilLaunch() {
    // time until Aug 15, 2023 00:00:00
    DateTime launchDate = DateTime(2023, 9, 1);
    Duration timeUntilLaunch = launchDate.difference(DateTime.now());
    return '${timeUntilLaunch.inDays} days and ${timeUntilLaunch.inHours.remainder(24)} hours';
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
              onPressed: widget.toggleRadio,
              icon: const LineIcon(LineIcons.music)
          ),
          IconButton(
            icon: const LineIcon(LineIcons.search),
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
        ],
      ),
      body: _isLoading ? SkeletonListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: 10,
          itemBuilder: (context, index) => PostComponent(post: Post.empty(), isSkeleton: true)
      ) : SmartRefresher(
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
            if (index == 0) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Text(_timeUntilLaunch(), style: Theme.of(context).textTheme.headlineLarge),
                  Text('Until Hoot is released', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 30),
                  OpenContainer(
                    closedColor: Theme.of(context).colorScheme.surface,
                    closedBuilder: (context, action) => PostComponent(post: post),
                    openBuilder: (context, action) => PostPage(post: post),
                  ),
                ],
              );
            } else if (index % 3 == 0) {
              return Column(
                children: [
                  OpenContainer(
                    closedColor: Theme.of(context).colorScheme.surface,
                    closedBuilder: (context, action) => PostComponent(post: post),
                    openBuilder: (context, action) => PostPage(post: post),
                  ),
                  const NativeAdComponent(),
                  const Divider(
                    thickness: 1,
                  ),
                ],
              );
            } else {
              return OpenContainer(
                closedColor: Theme.of(context).colorScheme.surface,
                closedBuilder: (context, action) => PostComponent(post: post),
                openBuilder: (context, action) => PostPage(post: post),
              );
            }
          },
        ) : Center(
          child: NothingToShowComponent(
            icon: const Icon(Icons.newspaper_rounded),
            text: '${AppLocalizations.of(context)!.noHoots}\n${AppLocalizations.of(context)!.subscribeToSeeHoots}',
          ),
        ),
      ),
    );
  }
}
