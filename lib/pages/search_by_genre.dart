import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/subscribe_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/feed_types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchByGenrePage extends StatefulWidget {
  FeedType type;
  SearchByGenrePage({super.key, required this.type});

  @override
  State<SearchByGenrePage> createState() => _SearchByGenrePageState();
}

class _SearchByGenrePageState extends State<SearchByGenrePage> {
  late FeedProvider _feedProvider;
  late RefreshController _refreshController;
  List<Feed> _results = [];

  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _refreshController = RefreshController(initialRefresh: true);
    super.initState();
  }

  Future _getResults(String startAtId) async {
    setState(() => { });
    List<Feed> feeds = await _feedProvider.searchFeedsByType(widget.type, startAtId);
    setState(() {
      _results = feeds;
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  bool _isPopular(FeedType type) => _feedProvider.popularTypes.contains(type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.searchForGenreFeeds(FeedTypeExtension.toTranslatedString(context, widget.type))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: DropdownButton(
                isExpanded: true,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  value: widget.type,
                  items: FeedType.values.map((FeedType feedType) {
                    return DropdownMenuItem(
                      value: feedType,
                      child: Row(
                        children: [
                          Icon(FeedTypeExtension.toIcon(feedType)),
                          const SizedBox(width: 10),
                          Text(FeedTypeExtension.toTranslatedString(context, feedType)),
                          const Spacer(),
                          if (_isPopular(feedType)) const Icon(Icons.whatshot_rounded, color: Colors.red),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (FeedType? value) {
                    if (value != null) {
                      setState(() {
                        widget.type = value;
                        _refreshController.requestRefresh();
                      });
                    }
                  },
              ),
            ),
            Expanded(
              child: SmartRefresher(
                onRefresh: () async => await _getResults('first'),
                onLoading: () async => await _getResults(_results.last.id),
                controller: _refreshController,
                enablePullUp: true,
                child: _results.isNotEmpty ? ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => Navigator.pushNamed(context, '/profile', arguments: [_results[index].user, _results[index].id]),
                      title: Text(_results[index].title),
                      subtitle: Text(_results[index].description!),
                      leading: ProfileAvatarComponent(
                        image: _results[index].user!.smallProfilePictureUrl ?? '',
                        size: 40
                      ),
                      trailing: SubscribeComponent(feed: _results[index], user: _results[index].user!),
                    );
                  },
                ) : !_refreshController.isLoading && !_refreshController.isRefresh ? NothingToShowComponent(
                    icon: const Icon(Icons.search_off_rounded),
                    text: AppLocalizations.of(context)!.noResults,
                ) : const SizedBox(),
              ),
            ),
          ],
        ),
      )
    );
  }
}
