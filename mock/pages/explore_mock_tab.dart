import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:solar_icons/solar_icons.dart';

import 'package:hoot/components/feed_card.dart';
import 'package:hoot/components/type_box_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/util/enums/feed_types.dart';

class ExploreMockTab extends StatefulWidget {
  const ExploreMockTab({super.key});

  @override
  State<ExploreMockTab> createState() => _ExploreMockTabState();
}

class _ExploreMockTabState extends State<ExploreMockTab> {
  List<String> popularUsers = [];
  List<Feed> topFeeds = [];
  List<FeedType> genres = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jsonString =
        await rootBundle.loadString('mock/data/sample_explore.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;

    setState(() {
      popularUsers =
          List<String>.from(data['popularUsers'] as List<dynamic>? ?? []);
      topFeeds = (data['topFeeds'] as List<dynamic>? ?? [])
          .map((e) => Feed.fromJson(e as Map<String, dynamic>))
          .toList();
      genres = (data['genres'] as List<dynamic>? ?? [])
          .map((e) => FeedTypeExtension.fromString(e as String))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(SolarIconsOutline.magnifier),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Popular Users',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: popularUsers.length,
              itemBuilder: (context, index) {
                final image = popularUsers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ProfileAvatarComponent(
                    image: image,
                    size: 80,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(38),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 42),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Top 10 Most Subscribed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              itemCount: topFeeds.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final feed = topFeeds[index];
                return FeedCard(feed: feed, onTap: () {});
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Popular Types',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              itemCount: genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final type = genres[index];
                return TypeBoxComponent(type: type);
              },
            ),
          ),
        ],
      ),
    );
  }
}
