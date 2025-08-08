import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/services/toast_service.dart';

class StaffImportController extends GetxController {
  StaffImportController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final TextEditingController jsonController = TextEditingController();

  Timestamp? _toTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value;
    if (value is num) {
      return Timestamp.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      final ms = int.tryParse(value);
      if (ms != null) {
        return Timestamp.fromMillisecondsSinceEpoch(ms);
      }
      return Timestamp.fromDate(DateTime.parse(value));
    }
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    return null;
  }

  void _convertTimestamps(Map<String, dynamic> map) {
    for (final key in List<String>.from(map.keys)) {
      if (key.endsWith('At') ||
          key.endsWith('Date') ||
          key == 'birthday' ||
          key.endsWith('LastReset')) {
        final ts = _toTimestamp(map[key]);
        if (ts != null) {
          map[key] = ts;
        } else if (map[key] == null) {
          map.remove(key);
        }
      }
    }
  }

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

    final firestore = _firestore;
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
        _convertTimestamps(userData);
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
          _convertTimestamps(feedData);

          batch.set(feedRef, feedData);

          final feedSubRef = feedRef.collection('subscribers').doc(uid);
          final userSubRef = userRef.collection('subscriptions').doc(feedId);
          batch.set(feedSubRef, {
            'createdAt':
                _toTimestamp(feed['createdAt']) ?? FieldValue.serverTimestamp()
          });
          batch.set(userSubRef, {
            'createdAt':
                _toTimestamp(feed['createdAt']) ?? FieldValue.serverTimestamp()
          });

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
            _convertTimestamps(postData);
            batch.set(firestore.collection('posts').doc(postId), postData);
          }
        }

        for (final sub in subs) {
          if (sub is Map) {
            final subData = Map<String, dynamic>.from(sub);
            final feedId = subData.remove('id') ?? subData.remove('feedId');
            if (feedId == null || ownedFeeds.contains(feedId)) continue;
            _convertTimestamps(subData);
            final feedRef = firestore.collection('feeds').doc(feedId);
            final feedSubRef = feedRef.collection('subscribers').doc(uid);
            final userSubRef = userRef.collection('subscriptions').doc(feedId);
            batch.set(feedSubRef, Map<String, dynamic>.from(subData));
            batch.set(userSubRef, Map<String, dynamic>.from(subData));
          } else {
            final feedId = sub is String ? sub : null;
            if (feedId == null || ownedFeeds.contains(feedId)) continue;
            final feedRef = firestore.collection('feeds').doc(feedId);
            final feedSubRef = feedRef.collection('subscribers').doc(uid);
            final userSubRef = userRef.collection('subscriptions').doc(feedId);
            batch.set(feedSubRef, {'createdAt': FieldValue.serverTimestamp()});
            batch.set(userSubRef, {'createdAt': FieldValue.serverTimestamp()});
          }
        }
      }

      await batch.commit();
      try {
        ToastService.showSuccess('Data imported');
      } catch (_) {}
    } catch (e) {
      try {
        ToastService.showError('Import failed');
      } catch (_) {}
    }
  }

  @override
  void onClose() {
    jsonController.dispose();
    super.onClose();
  }
}
