import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_mentions/flutter_mentions.dart';

import 'package:hoot/models/post.dart';
import 'package:hoot/models/comment.dart';
import 'package:hoot/services/comment_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/user_service.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/report_service.dart';
import 'package:hoot/services/toast_service.dart';

class PostController extends GetxController {
  final Rx<Post> post = Post.empty().obs;
  final CommentService _commentService;
  final AuthService _authService;
  final PostService _postService;
  final ReportService _reportService;
  UserService? _userService;

  PostController({
    CommentService? commentService,
    AuthService? authService,
    UserService? userService,
    PostService? postService,
    ReportService? reportService,
  })  : _commentService = commentService ?? CommentService(),
        _authService = authService ?? Get.find<AuthService>(),
        _postService = postService ?? Get.find<PostService>(),
        _reportService = reportService ?? ReportService(),
        _userService = userService;

  final Rx<PagingState<DocumentSnapshot?, Comment>> commentsState =
      PagingState<DocumentSnapshot?, Comment>().obs;
  final TextEditingController commentController = TextEditingController();
  final GlobalKey<FlutterMentionsState> commentKey =
      GlobalKey<FlutterMentionsState>();
  final RxList<Map<String, dynamic>> mentionSuggestions =
      <Map<String, dynamic>>[].obs;
  final RxBool postingComment = false.obs;
  final RxBool showSendButton = false.obs;

  String? get currentUserId => _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Post) {
      post.value = args;
      _setup();
    } else if (args is Map && args['post'] is Post) {
      post.value = args['post'];
      _setup();
    } else if (args is String) {
      _loadPost(args);
    } else if (args is Map && args['id'] is String) {
      _loadPost(args['id']);
    } else {
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
      post.value = fetched;
    }
    _setup();
  }

  void fetchNextComments() async {
    final current = commentsState.value;
    if (current.isLoading) return;

    commentsState.value = current.copyWith(isLoading: true, error: null);
    try {
      final page = await _commentService.fetchComments(
        post.value.id,
        startAfter: current.keys?.last,
      );
      commentsState.value = commentsState.value.copyWith(
        pages: [...?current.pages, page.comments],
        keys: [...?current.keys, page.lastDoc],
        hasNextPage: page.hasMore,
        isLoading: false,
      );
    } catch (e) {
      commentsState.value =
          commentsState.value.copyWith(error: e, isLoading: false);
      FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Failed to load comments',
      );
    }
  }

  @override
  Future<void> refresh() async {
    try {
      final fetched = await _postService.fetchPost(post.value.id);
      if (fetched != null) {
        post.value = fetched;
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Failed to refresh post',
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
      final id = _commentService.newCommentId(post.value.id);
      await _commentService.createComment(
          post.value.id,
          {
            'text': text,
            'postId': post.value.id,
            'userId': user.uid,
            'user': userData,
            'createdAt': FieldValue.serverTimestamp(),
          },
          id: id);

      commentController.clear();
      commentKey.currentState?.controller?.clear();

      final newComment = Comment(
        id: id,
        postId: post.value.id,
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
        commentsState.value =
            commentsState.value.copyWith(pages: [first, ...pages.skip(1)]);
      }
      post.value.comments = (post.value.comments ?? 0) + 1;
      post.refresh();
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

  Future<void> deleteComment(Comment comment) async {
    try {
      await _commentService.deleteComment(post.value.id, comment.id);
      final pages = commentsState.value.pages;
      if (pages != null) {
        final updated = pages
            .map((p) => p.where((c) => c.id != comment.id).toList())
            .toList();
        commentsState.value = commentsState.value.copyWith(pages: updated);
      }
      post.value.comments = (post.value.comments ?? 0) - 1;
      post.refresh();
      ToastService.showSuccess('commentDeleted'.tr);
    } catch (e) {
      ToastService.showError('somethingWentWrong'.tr);
    }
  }

  Future<void> reportComment(Comment comment, String reason) async {
    try {
      await _reportService.reportComment(commentId: comment.id, reason: reason);
      ToastService.showSuccess('reportSent'.tr);
    } catch (e) {
      ToastService.showError('somethingWentWrong'.tr);
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
