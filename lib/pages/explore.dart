import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/components/name_component.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';
import '../services/auth_provider.dart';
import '../services/feed_provider.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late AuthProvider _authProvider;
  late FeedProvider _feedProvider;
  late Gallery3DController _gallery3DController;
  List<Feed> _top10Feeds = [];
  List<Feed> _recentFeeds = [];


  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    super.initState();
    _top10MostSubscribedFeeds();
    _recentlyAddedFeeds();
  }

  Future _top10MostSubscribedFeeds() async {
    List<Feed> feeds = _feedProvider.topFeeds.isEmpty ? await _feedProvider.top10MostSubscribedFeeds() : _feedProvider.topFeeds;
    setState(() {
      _top10Feeds = feeds;
      _gallery3DController = Gallery3DController(itemCount: feeds.length);
    });
  }

  Future _recentlyAddedFeeds() async {
    List<Feed> feeds = _feedProvider.newFeeds.isEmpty ? await _feedProvider.recentlyAddedFeeds() : _feedProvider.newFeeds;
    setState(() {
      _recentFeeds = feeds;
    });
  }

  Container _card(BuildContext context, int index) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Stack(
      children: [
        Positioned.fill(
            child: OctoImage(
              image: NetworkImage(_top10Feeds[index].user!.largeProfilePictureUrl ?? ''),
              fit: BoxFit.cover,
              placeholderBuilder: OctoPlaceholder.blurHash(
                'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
              ),
              errorBuilder: OctoError.icon(color: Colors.red),
            )
        ),
        Positioned(
            bottom: 0,
            child: SizedBox(
              width: 200,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Blur(
                        blur: 10,
                        blurColor: Colors.black.withOpacity(0.5),
                        child: Image.network(
                            _top10Feeds[index].user!.largeProfilePictureUrl ?? '',
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _top10Feeds[index].title ?? '',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white
                          )
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("by", style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white
                            )),
                            const SizedBox(width: 5),
                            NameComponent(user: _top10Feeds[index].user!, color: _top10Feeds[index].color!, textColor: Colors.white),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
        )
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.explore),
        ),
        body: _recentFeeds.isEmpty && _top10Feeds.isEmpty ? Center(
          child: LoadingAnimationWidget.inkDrop(
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _top10Feeds.isNotEmpty ? SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Blur(
                        blur: 20,
                        blurColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        child: Image.network(
                          _authProvider.user!.largeProfilePictureUrl ?? '',
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 50),
                        Text(
                          "Top 10 most subscribed feeds",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 30),
                        Gallery3D(
                          controller: _gallery3DController,
                          width: MediaQuery.of(context).size.width,
                          itemConfig: const GalleryItemConfig(
                            width: 200,
                            height: 300,
                            radius: 10,
                            shadows: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset.zero,
                                  blurRadius: 10,
                                  spreadRadius: 0
                              )
                            ]
                          ),
                          onClickItem: (index) => Navigator.of(context).pushNamed('/profile', arguments: [_top10Feeds[index].user, _top10Feeds[index].id]),
                          itemBuilder: (context, index) => _card(context, index),
                        )
                      ],
                    )
                  ],
                ),
              ) : Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: LoadingAnimationWidget.inkDrop(
                    size: 50,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Up and coming feeds",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Recent feeds that are gaining popularity",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    _recentFeeds.isNotEmpty ?
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentFeeds.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile', arguments: [_recentFeeds[index].user, _recentFeeds[index].id]),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _recentFeeds[index].color,
                                  gradient: LinearGradient(
                                    colors: [
                                      _recentFeeds[index].color!,
                                      _recentFeeds[index].color!.withOpacity(0.5)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    _recentFeeds[index].title![0].toUpperCase(),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _recentFeeds[index].title ?? '',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          "by",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 5),
                                        NameComponent(user: _recentFeeds[index].user!, color: _recentFeeds[index].color!, textColor: Theme.of(context).colorScheme.onSurface, bold: false, size: 12),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ) : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: LoadingAnimationWidget.inkDrop(
                          size: 50,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      "Note to ${_authProvider.user!.name}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Hoot is a place to explore one's creativity and identity. We encourage you to be yourself and express your creativity. Be it through feeds, hoots, comments, or anything else.\n\n"
                          "There's no contest to be the best or the most popular. There's no need to be the most subscribed feed or the most liked hoot. There's no need to be the most followed user or the most commented hoot.\n\n"
                          "Your experience is what you make of it and most of all, your people are ready to subscribe to you because your content is unique and so are you.\n\n"
                          "Hoot on!",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 100),
                  ],
                )
              ),
            ],
          ),
        )
    );
  }
}
