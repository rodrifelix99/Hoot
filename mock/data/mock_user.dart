import 'dart:ui';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';

/// Sample feed used by mock services.
final Feed mockFeed = Feed(
  id: 'feed1',
  userId: 'user1',
  title: 'General',
  description: 'Mock feed for testing',
  color: const Color(0xFF2196F3),
  subscriberCount: 1,
);

/// Generates a sample user for mock services.
U createMockUser({DateTime? createdAt}) {
  return U(
    uid: 'user1',
    name: 'Mock User',
    username: 'mockuser',
    createdAt: createdAt ?? DateTime(2020, 1, 1),
    feeds: [mockFeed],
    subscriptionCount: 1,
  );
}

/// Default mock user instance.
final U mockUser = createMockUser();
