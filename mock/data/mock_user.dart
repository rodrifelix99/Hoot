import 'dart:ui';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';

/// Sample user used by mock services.
final Feed mockFeed = Feed(
  id: 'feed1',
  userId: 'user1',
  title: 'General',
  description: 'Mock feed for testing',
  color: const Color(0xFF2196F3),
  subscriberCount: 1,
);

final U mockUser = U(
  uid: 'user1',
  name: 'Mock User',
  username: 'mockuser',
  feeds: [mockFeed],
  subscriptionCount: 1,
);
