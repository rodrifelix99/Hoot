import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:solar_icons/solar_icons.dart';

import 'package:hoot/util/enums/app_colors.dart';

class HomeMockPage extends StatefulWidget {
  const HomeMockPage({super.key});

  @override
  State<HomeMockPage> createState() => _HomeMockPageState();
}

class _HomeMockPageState extends State<HomeMockPage> {
  List<dynamic> posts = [];
  int selectedIndex = 0;
  int unreadCount = 3;
  final AppColor appColor = AppColor.blue;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final jsonString =
        await rootBundle.loadString('mock/data/sample_posts.json');
    final data = json.decode(jsonString) as List<dynamic>;
    setState(() {
      posts = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final user = post['user'] as Map<String, dynamic>? ?? {};
          return ListTile(
            title: Text(user['username'] ?? ''),
            subtitle: Text(post['text'] ?? ''),
          );
        },
      ),
      const Center(child: Text('Explore')),
      const Center(child: Text('Notifications')),
      const Center(child: Text('Profile')),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(appColor.asset, fit: BoxFit.cover),
          if (Theme.of(context).brightness == Brightness.dark)
            Container(color: Colors.black.withAlpha(125)),
          SafeArea(
            top: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom
              : 16,
          left: MediaQuery.of(context).padding.left + 16,
          right: MediaQuery.of(context).padding.right + 16,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                iconSize: 24,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildNavItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems() {
    return [
      IconButton(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        icon: Icon(
          SolarIconsOutline.feed,
          color:
              selectedIndex == 0 ? Colors.white : Colors.white.withAlpha(175),
        ),
        onPressed: () => setState(() => selectedIndex = 0),
      ),
      IconButton(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        icon: Icon(
          SolarIconsOutline.compass,
          color:
              selectedIndex == 1 ? Colors.white : Colors.white.withAlpha(175),
        ),
        onPressed: () => setState(() => selectedIndex = 1),
      ),
      IconButton(
        iconSize: 50,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          SolarIconsBold.addSquare,
          color: Colors.white.withAlpha(175),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create post')),
          );
        },
      ),
      Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            icon: Icon(
              SolarIconsOutline.bell,
              color: selectedIndex == 2
                  ? Colors.white
                  : Colors.white.withAlpha(175),
            ),
            onPressed: () => setState(() {
              selectedIndex = 2;
              unreadCount = 0;
            }),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: TextStyle(
                    color: Colors.black.withAlpha(150),
                    fontSize: 10,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      IconButton(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        icon: Icon(
          SolarIconsOutline.user,
          color:
              selectedIndex == 3 ? Colors.white : Colors.white.withAlpha(175),
        ),
        onPressed: () => setState(() => selectedIndex = 3),
      ),
    ];
  }
}
