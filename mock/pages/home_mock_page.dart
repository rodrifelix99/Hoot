import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeMockPage extends StatefulWidget {
  const HomeMockPage({super.key});

  @override
  State<HomeMockPage> createState() => _HomeMockPageState();
}

class _HomeMockPageState extends State<HomeMockPage> {
  List<dynamic> posts = [];

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
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.builder(
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
    );
  }
}
