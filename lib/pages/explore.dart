import 'package:blur/blur.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/components/name_component.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
    });
  }

  Future _recentlyAddedFeeds() async {
    List<Feed> feeds = _feedProvider.newFeeds.isEmpty ? await _feedProvider.recentlyAddedFeeds() : _feedProvider.newFeeds;
    setState(() {
      _recentFeeds = feeds;
    });
  }

  Widget _card(BuildContext context, int index) => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Stack(
        children: [
          Positioned.fill(
            child: Blur(
                blur: 25,
                blurColor: _top10Feeds[index].color!.withOpacity(0.5),
                child: Image.network(
                    _top10Feeds[index].user!.largeProfilePictureUrl ?? '',
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: double.infinity,
                    fit: BoxFit.cover
                )
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _top10Feeds[index].nsfw == true ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Icon(Icons.warning_rounded, color: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                  )
                      : _top10Feeds[index].private == true ? Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Icon(Icons.lock_rounded, color:_top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                      )
                      : const SizedBox(),
                  Text(
                      _top10Feeds[index].title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white
                      )
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.by, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white
                      )),
                      const SizedBox(width: 5),
                      NameComponent(
                          user: _top10Feeds[index].user!,
                          color: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          textColor: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                      _top10Feeds[index].description ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white
                      )
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      AppLocalizations.of(context)!.numberOfSubscribers(_top10Feeds[index].subscribers?.length ?? 0),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white
                      )
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.people, color: _top10Feeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 15),
                ],
              ),
            ),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.explore),
          actions: [
            IconButton(
              icon: const Icon(LineIcons.search),
              onPressed: () => Navigator.of(context).pushNamed('/search'),
            ),
          ],
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
                          AppLocalizations.of(context)!.top10MostSubscribed,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 30),
                        Swiper(
                          itemCount: _top10Feeds.length,
                          itemWidth: MediaQuery.of(context).size.width * 0.8,
                          itemHeight: MediaQuery.of(context).size.width * 0.9,
                          layout: SwiperLayout.STACK,
                          onTap: (index) => Navigator.pushNamed(context, '/profile', arguments: [_top10Feeds[index].user, _top10Feeds[index].id]),
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
                        AppLocalizations.of(context)!.upAndComing,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.upAndComingDescription,
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
                                      _recentFeeds[index].title[0].toUpperCase(),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: _recentFeeds[index].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white
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
                                        _recentFeeds[index].title,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.by,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          const SizedBox(width: 5),
                                          NameComponent(
                                              user: _recentFeeds[index].user!,
                                              color: Theme.of(context).colorScheme.onSurface,
                                              textColor: Theme.of(context).colorScheme.onSurface,
                                              bold: false,
                                              size: 12
                                          ),
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
                        AppLocalizations.of(context)!.noteToUser(_authProvider.user!.name!),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.noteToUserDetails,
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
