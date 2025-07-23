import 'package:flutter/material.dart';
import 'package:hoot/models/user.dart';

class ReportPage extends StatelessWidget {
  final U user;
  final String postId;
  final String feedId;
  const ReportPage({super.key, required this.user, this.postId = '', this.feedId = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report @${user.username}'),
      ),
      body: const Center(
        child: Text('Report'),
      )
    );
  }
}
