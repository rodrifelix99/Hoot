import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_mentions/flutter_mentions.dart';

import '../../../models/post.dart';
import '../../../models/comment.dart';
import '../../../services/comment_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../services/post_service.dart';

class PostController extends GetxController {
  late Post post;
  final BaseCommentService _commentService;
  final AuthService _authService;
  final BasePostService _postService;
  BaseUserService? _userService;

  PostController({
    BaseCommentService? commentService,
    AuthService? authService,
    BaseUserService? userService,
    BasePostService? postService,
  })  : _commentService = commentService ?? CommentService(),
        _authService = authService ?? Get.find<AuthService>(),
        _postService = postService ?? Get.find<BasePostService>(),
        _userService = userService;

  final Rx<PagingState<DocumentSnapshot?, Comment>> commentsState = PagingState<DocumentSnapshot?, Comment>().obs;
  final TextEditingController commentController = TextEditingController();
  final GlobalKey<FlutterMentionsState> commentKey = GlobalKey<FlutterMentionsState>();
  final RxList<Map<String, dynamic>> mentionSuggestions = <Map<String, dynamic>>[].obs;
  final RxBool postingComment = false.obs;
  final RxBool showSendButton = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Post) {
      post = args;
      _setup();
    } else if (args is Map && args['post'] is Post) {
      post = args['post'];
      _setup();
    } else if (args is String) {
      post = Post.empty();
      _loadPost(args);
    } else if (args is Map && args['id'] is String) {
      post = Post.empty();
      _loadPost(args['id']);
    } else {
      post = Post.empty();
      _setup();
    }
  }

  void _setup() {
    commentController.addListener(() {
      showSendButton.value = commentController.text.trim().isNotEmpty;
    });
    fetchNextComments();
  }

  Future<void> _loadPost(String id) async {
    final fetched = await _postService.fetchPost(id);
    if (fetched != null) {
      post = fetched;
      update();
    }
    _setup();
  }

  void fetchNextComments() async {
    final current = commentsState.value;
    if (current.isLoading) return;

    commentsState.value = current.copyWith(isLoading: true, error: null);
    try {
      final page = await _commentService.fetchComments(
        post.id,
        startAfter: current.keys?.last,
      );
      commentsState.value = commentsState.value.copyWith(
        pages: [...?current.pages, page.comments],
        keys: [...?current.keys, page.lastDoc],
        hasNextPage: page.hasMore,
        isLoading: false,
      );
    } catch (e) {
      commentsState.value = commentsState.value.copyWith(error: e, isLoading: false);
      FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Failed to load comments',
      );
    }
  }

  /// Searches users for mentions in comments.
  Future<void> searchUsers(String query) async {
    _userService ??= UserService();
    final users = await _authService.searchUsers(query);
    mentionSuggestions.assignAll(users.map((u) => {
          'id': u.uid,
          'display': u.username ?? '',
          'photo': u.smallProfilePictureUrl,
        }));
  }

  Future<void> publishComment() async {
    if (postingComment.value) return;
    final text = commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final user = _authService.currentUser;
    if (user == null) return;

    postingComment.value = true;
    try {
      final userData = user.toJson();
      userData['uid'] = user.uid;
      final id = _commentService.newCommentId(post.id);
      await _commentService.createComment(
          post.id,
          {
            'text': text,
            'postId': post.id,
            'userId': user.uid,
            'user': userData,
            'createdAt': FieldValue.serverTimestamp(),
          },
          id: id);

      commentController.clear();
      commentKey.currentState?.controller?.clear();

      final newComment = Comment(
        id: id,
        postId: post.id,
        text: text,
        user: user,
        createdAt: DateTime.now(),
      );
      final pages = commentsState.value.pages;
      if (pages == null || pages.isEmpty) {
        commentsState.value = commentsState.value.copyWith(pages: [
          [newComment]
        ]);
      } else {
        final first = List<Comment>.from(pages.first);
        first.insert(0, newComment);
        commentsState.value = commentsState.value.copyWith(pages: [first, ...pages.skip(1)]);
      }
      post.comments = (post.comments ?? 0) + 1;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Failed to publish comment',
      );
    } finally {
      postingComment.value = false;
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
