import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/services/toast_service.dart';

class StaffImportController extends GetxController {
  final TextEditingController jsonController = TextEditingController();

  Future<void> importData() async {
    final text = jsonController.text.trim();
    List<Map<String, dynamic>> users;
    try {
      final parsed = jsonDecode(text);
      if (parsed is! List) {
        ToastService.showError('JSON must be a list of users');
        return;
      }
      users = List<Map<String, dynamic>>.from(parsed);
    } catch (e) {
      ToastService.showError('Invalid JSON');
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    try {
      for (final user in users) {
        final uid = user['uid'];
        final username = user['username'];
        if (uid == null || username == null) {
          ToastService.showError('User missing uid or username');
          return;
        }
        final userRef = firestore.collection('users').doc(uid);
        final userData = Map<String, dynamic>.from(user)
          ..['usernameLowercase'] = username.toString().toLowerCase();
        final feeds =
            List<Map<String, dynamic>>.from(userData.remove('feeds') ?? []);
        final subs = List.from(userData.remove('subscriptions') ?? []);
        batch.set(userRef, userData);

        final ownedFeeds = <String>{};
        for (final feed in feeds) {
          final feedId = feed['id'];
          if (feedId == null) {
            ToastService.showError('Feed missing id for user $uid');
            return;
          }
          ownedFeeds.add(feedId);
          final feedRef = firestore.collection('feeds').doc(feedId);
          final feedData = Map<String, dynamic>.from(feed)..['userId'] = uid;
          final posts =
              List<Map<String, dynamic>>.from(feedData.remove('posts') ?? []);

          batch.set(feedRef, feedData);

          final feedSubRef = feedRef.collection('subscribers').doc(uid);
          final userSubRef = userRef.collection('subscriptions').doc(feedId);
          batch.set(feedSubRef, {'createdAt': FieldValue.serverTimestamp()});
          batch.set(userSubRef, {'createdAt': FieldValue.serverTimestamp()});

          final feedMap = {...feedData, 'id': feedId, 'userId': uid};
          final userMap = {...userData, 'uid': uid};

          for (final post in posts) {
            final postId = post['id'] ?? firestore.collection('posts').doc().id;
            final postData = Map<String, dynamic>.from(post)
              ..remove('id')
              ..['feedId'] = feedId
              ..['feed'] = feedMap
              ..['userId'] = uid
              ..['user'] = userMap;
            batch.set(firestore.collection('posts').doc(postId), postData);
          }
        }

        for (final sub in subs) {
          final feedId = sub is String ? sub : (sub is Map ? sub['id'] : null);
          if (feedId == null || ownedFeeds.contains(feedId)) continue;
          final feedRef = firestore.collection('feeds').doc(feedId);
          final feedSubRef = feedRef.collection('subscribers').doc(uid);
          final userSubRef = userRef.collection('subscriptions').doc(feedId);
          batch.set(feedSubRef, {'createdAt': FieldValue.serverTimestamp()});
          batch.set(userSubRef, {'createdAt': FieldValue.serverTimestamp()});
        }
      }

      await batch.commit();
      ToastService.showSuccess('Data imported');
    } catch (e) {
      ToastService.showError('Import failed');
    }
  }

  @override
  void onClose() {
    jsonController.dispose();
    super.onClose();
  }
}
