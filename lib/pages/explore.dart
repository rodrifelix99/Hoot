import 'package:animations/animations.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/list_item_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/subscribe_component.dart';
import 'package:hoot/components/type_box_component.dart';
import 'package:hoot/pages/profile.dart';
import 'package:hoot/pages/search_by_genre.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/feed.dart';
import '../models/feed_types.dart';
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
  List<FeedType> _popularTypes = [];

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    super.initState();
    _top10MostSubscribedFeeds();
    _getPopularTypes();
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

  Future _getPopularTypes() async {
    List<FeedType> types = _feedProvider.popularTypes.isEmpty ? await _feedProvider.getPopularTypes() : _feedProvider.popularTypes;
    setState(() {
      _popularTypes = types;
      print(_popularTypes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          title: AppLocalizations.of(context)!.explore,
          actions: [
            IconButton(
              icon: const Icon(SolarIconsOutline.magnifier),
              onPressed: () => Navigator.of(context).pushNamed('/search'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _top10Feeds.isNotEmpty ? SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          for (int i = 0; i < _top10Feeds.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: OpenContainer(
                                closedElevation: 0,
                                closedShape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                transitionType: ContainerTransitionType.fadeThrough,
                                closedBuilder: (context, open) => Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                                    minWidth: MediaQuery.of(context).size.width * 0.4,
                                  ),
                                  height: 240,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        top: 50,
                                        child: Container(
                                          width: 232,
                                          height: 179,
                                          decoration: ShapeDecoration(
                                            color: _top10Feeds[i].color?.withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 10,
                                        left: 10,
                                        top: 195,
                                        child: SizedBox(
                                          width: 164,
                                          child: Text(
                                            '${AppLocalizations.of(context)!.by} ${_top10Feeds[i].user!.name}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                                              fontSize: 14,
                                              height: 1.57,
                                              letterSpacing: -0.41,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        //center
                                        left: MediaQuery.of(context).size.width * 0.6 / 2 - 75,
                                        right: MediaQuery.of(context).size.width * 0.6 / 2 - 75,
                                        top: 0,
                                        child: Container(
                                          width: 150,
                                          height: 150,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(40),
                                            ),
                                            shadows: const [
                                              BoxShadow(
                                                color: Color(0x26000000),
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                                spreadRadius: 0,
                                              )
                                            ],
                                          ),
                                          child: ProfileAvatarComponent(
                                            image: _top10Feeds[i].user?.largeProfilePictureUrl ?? '',
                                            size: 150,
                                            radius: 40,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        right: 10,
                                        top: 169,
                                        child: Text(
                                          _top10Feeds[i].title,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            height: 1.10,
                                            letterSpacing: -0.41,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                openBuilder: (context, close) => ProfilePage(
                                  feedId: _top10Feeds[i].id,
                                  user: _top10Feeds[i].user,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
                child: Text(
                  AppLocalizations.of(context)!.popularTypes,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(AppLocalizations.of(context)!.popularTypesDescription, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _popularTypes.isNotEmpty ?  [
                    for (FeedType type in _popularTypes) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: OpenContainer(
                          closedColor: Colors.transparent,
                          closedElevation: 0,
                          closedBuilder: (context, open) => TypeBoxComponent(type: type),
                          openBuilder: (context, close) => SearchByGenrePage(type: type)
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/search_by_genre', arguments: FeedType.general),
                        child: const TypeBoxComponent(type: FeedType.other, isLast: true)
                    ),
                    const SizedBox(width: 20),
                  ] : [
                    const SizedBox(width: 20),
                    const TypeBoxComponent(type: FeedType.general, isSkeleton: true),
                    const SizedBox(width: 10),
                    const TypeBoxComponent(type: FeedType.general, isSkeleton: true),
                    const SizedBox(width: 20),
                  ],
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
                        style: Theme.of(context).textTheme.titleLarge,
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
                              child: OpenContainer(
                                closedElevation: 0,
                                transitionType: ContainerTransitionType.fadeThrough,
                                closedShape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                closedBuilder: (context, open) => ListItemComponent(
                                  title: _recentFeeds[index].title,
                                  subtitle: _recentFeeds[index].description ?? '',
                                  backgroundColor: _recentFeeds[index].color?.withOpacity(.15) ?? Theme.of(context).colorScheme.surface,
                                  // if feed color too bright, use surface color
                                  foregroundColor: _recentFeeds[index].color!.computeLuminance() > 0.5 ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onBackground,
                                  leading: ProfileAvatarComponent(
                                    image: _recentFeeds[index].user?.largeProfilePictureUrl ?? '',
                                    size: 100,
                                    radius: 25,
                                  ),
                                  trailing: SubscribeComponent(
                                    feed: _recentFeeds[index],
                                    user: _recentFeeds[index].user!,
                                  ),
                                ),
                                openBuilder: (context, close) => ProfilePage(
                                  feedId: _recentFeeds[index].id,
                                  user: _recentFeeds[index].user,
                                ),
                              )
                          ),
                        ),
                      ) : const Column(
                        children: [
                          ListItemComponent(
                            title: '',
                            subtitle: '',
                            leading: SizedBox.shrink(),
                            isLoading: true,
                          ),
                          ListItemComponent(
                            title: '',
                            subtitle: '',
                            leading: SizedBox.shrink(),
                            isLoading: true,
                          ),
                          ListItemComponent(
                            title: '',
                            subtitle: '',
                            leading: SizedBox.shrink(),
                            isLoading: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.noteToUser(_authProvider.user!.name!.split(' ')[0]),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.noteToUserDetails,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
              ),
            ],
          ),
        )
    );
  }
}
