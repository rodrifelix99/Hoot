import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:solar_icons/solar_icons.dart';

import 'package:hoot/models/user.dart';

/// A component that allows the user to subscribe to a feed and manage requests
class SubscribeComponent extends StatefulWidget {
  /// The feed to subscribe to
  final Feed feed;

  /// The user that owns the feed
  final U user;
  const SubscribeComponent({super.key, required this.feed, required this.user});

  @override
  State<SubscribeComponent> createState() => _SubscribeComponentState();
}

class _SubscribeComponentState extends State<SubscribeComponent> {
  late AuthController _authProvider;
  late FeedController _feedProvider;

  bool _subscribeCooldown = false;
  bool _requestCooldown = false;

  @override
  void initState() {
    _feedProvider = Get.find<FeedController>();
    _authProvider = Get.find<AuthController>();
    super.initState();
  }

  bool _isAuthor() {
    return widget.user.uid == _authProvider.user?.uid;
  }

  bool _isSubscribed() {
    return widget.feed.subscribers?.contains(_authProvider.user?.uid) ?? false;
  }

  bool _isPrivate() {
    return widget.feed.private ?? false;
  }

  bool _isRequested() {
    return widget.feed.requests?.contains(_authProvider.user?.uid) ?? false;
  }

  bool _hasRequests() {
    return (widget.feed.requests?.length ?? 0) > 0;
  }

  Future _requestToJoinFeed() async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('requestToJoin'.tr),
              content: Text('requestToJoinConfirmation'.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel'.tr),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('requestToJoin'.tr),
                ),
              ],
            ));
    if (confirm) {
      if (_requestCooldown) {
        // TODO: Use ToastService.showInfo 'youAreGoingTooFast'.tr
        return;
      }
      setState(() => widget.feed.requests!.add(_authProvider.user!.uid));
      bool res = await _feedProvider.requestToJoinFeed(
          widget.user.uid, widget.feed.id);
      !res
          ? setState(() {
              widget.feed.requests!.remove(_authProvider.user!.uid);
              // TODO: Use ToastService.showError and handle error 'errorRequestingToJoin'.tr
            })
          : null;
      setState(() => _requestCooldown = true);
      Future.delayed(const Duration(seconds: 60),
          () => setState(() => _requestCooldown = false));
    }
  }

  Future _subscribeToFeed() async {
    if (_subscribeCooldown) {
      // TODO: Use ToastService.showInfo and handle error 'youAreGoingTooFast'.tr
      return;
    }
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('subscribe'.tr),
              content: Text('subscribeConfirmation'.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel'.tr),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('subscribe'.tr),
                ),
              ],
            ));
    if (confirm) {
      setState(() => widget.feed.subscribers!.add(_authProvider.user!.uid));
      bool res =
          await _feedProvider.subscribeToFeed(widget.user.uid, widget.feed.id);
      !res
          ? setState(() {
              widget.feed.subscribers!.remove(_authProvider.user!.uid);
              // TODO: Use ToastService.showError and handle error 'errorSubscribing'.tr
            })
          : null;
      setState(() => _subscribeCooldown = true);
      Future.delayed(const Duration(seconds: 60),
          () => setState(() => _subscribeCooldown = false));
    }
  }

  Future _unsubscribeFromFeed() async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('unsubscribe'.tr),
              content: Text('unsubscribeConfirmation'.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel'.tr),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('unsubscribe'.tr),
                ),
              ],
            ));
    if (confirm) {
      setState(() => widget.feed.subscribers!.remove(_authProvider.user!.uid));
      bool res = await _feedProvider.unsubscribeFromFeed(
          widget.user.uid, widget.feed.id);
      !res
          ? setState(() {
              widget.feed.subscribers!.add(_authProvider.user!.uid);
              // TODO: Use ToastService.showError and handle error 'errorUnsubscribing'.tr
            })
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthor() && _hasRequests()) {
      return ElevatedButton(
          onPressed: () => Navigator.of(context)
              .pushNamed('/feed_requests', arguments: widget.feed.id),
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: WidgetStateProperty.all<double>(0),
              textStyle: WidgetStateProperty.all<TextStyle>(
                  Theme.of(context).textTheme.bodyMedium!),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color!.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white)),
          child: Text('numberOfRequests'
              .trParams({'value': (widget.feed.requests?.length ?? 0).toString()})));
    } else if (_isAuthor()) {
      return const SizedBox.shrink();
    } else if (_isSubscribed()) {
      return IconButton(
          onPressed: _unsubscribeFromFeed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: WidgetStateProperty.all<double>(0),
              textStyle: WidgetStateProperty.all<TextStyle>(
                  Theme.of(context).textTheme.bodyMedium!),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).colorScheme.errorContainer),
              foregroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).colorScheme.onErrorContainer)),
          icon: const Icon(SolarIconsBold.homeAngle));
    } else if (_isPrivate() && !_isRequested()) {
      return IconButton(
          onPressed: _requestToJoinFeed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: WidgetStateProperty.all<double>(0),
              textStyle: WidgetStateProperty.all<TextStyle>(
                  Theme.of(context).textTheme.bodyMedium!),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color!.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white)),
          icon: const Icon(SolarIconsOutline.lockKeyholeMinimalistic));
    } else if (_isPrivate() && _isRequested()) {
      return ElevatedButton(
          onPressed: null,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: WidgetStateProperty.all<double>(0),
              textStyle: WidgetStateProperty.all<TextStyle>(
                  Theme.of(context).textTheme.bodyMedium!),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color!.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white)),
          child: Text('requested'.tr));
    } else {
      return IconButton(
          onPressed: _subscribeToFeed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: WidgetStateProperty.all<double>(0),
              textStyle: WidgetStateProperty.all<TextStyle>(
                  Theme.of(context).textTheme.bodyMedium!),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: WidgetStateProperty.all<Color>(
                  widget.feed.color!.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white)),
          icon: const Icon(SolarIconsOutline.homeAddAngle));
    }
  }
}
