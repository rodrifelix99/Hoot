import 'package:flutter/material.dart';
import 'package:hoot/models/feed.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import '../models/user.dart';
import '../services/error_service.dart';
import '../services/feed_provider.dart';
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
  late AuthProvider _authProvider;
  late FeedProvider _feedProvider;

  bool _subscribeCooldown = false;
  bool _requestCooldown = false;

  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
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
          title: Text(AppLocalizations.of(context)!.requestToJoin),
          content: Text(AppLocalizations.of(context)!.requestToJoinConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.requestToJoin),
            ),
          ],
        )
    );
    if (confirm) {
      if (_requestCooldown) {
        ToastService.showToast(
            context, AppLocalizations.of(context)!.youAreGoingTooFast, true);
        return;
      }
      setState(() => widget.feed.requests!.add(_authProvider.user!.uid));
      bool res = await _feedProvider.requestToJoinFeed(widget.user.uid, widget.feed.id);
      !res ? setState(() {
        widget.feed.requests!.remove(_authProvider.user!.uid);
        ToastService.showToast(context, AppLocalizations.of(context)!.errorRequestingToJoin, true);
      }) : null;
      setState(() => _requestCooldown = true);
      Future.delayed(const Duration(seconds: 60), () => setState(() => _requestCooldown = false));
    }
  }

  Future _subscribeToFeed() async {
    if (_subscribeCooldown) {
      ToastService.showToast(
          context, AppLocalizations.of(context)!.youAreGoingTooFast, true);
      return;
    }
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.subscribe),
          content: Text(AppLocalizations.of(context)!.subscribeConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.subscribe),
            ),
          ],
        )
    );
    if (confirm) {
      setState(() =>  widget.feed.subscribers!.add(_authProvider.user!.uid));
      bool res = await _feedProvider.subscribeToFeed(widget.user.uid, widget.feed.id);
      !res ? setState(() {
        widget.feed.subscribers!.remove(_authProvider.user!.uid);
        ToastService.showToast(context, AppLocalizations.of(context)!.errorSubscribing, true);
      }) : null;
      setState(() => _subscribeCooldown = true);
      Future.delayed(const Duration(seconds: 60), () => setState(() => _subscribeCooldown = false));
    }
  }

  Future _unsubscribeFromFeed() async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.unsubscribe),
          content: Text(AppLocalizations.of(context)!.unsubscribeConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.unsubscribe),
            ),
          ],
        )
    );
    if (confirm) {
      setState(() => widget.feed.subscribers!.remove(_authProvider.user!.uid));
      bool res = await _feedProvider.unsubscribeFromFeed(widget.user.uid, widget.feed.id);
      !res ? setState(() {
        widget.feed.subscribers!.add(_authProvider.user!.uid);
        ToastService.showToast(context, AppLocalizations.of(context)!.errorUnsubscribing, true);
      }) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthor() && _hasRequests()) {
      return ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/feed_requests', arguments: widget.feed.id),
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: MaterialStateProperty.all<double>(0),
              textStyle: MaterialStateProperty.all<TextStyle>(Theme.of(context).textTheme.bodyMedium!),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: MaterialStateProperty.all<Color>(widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: MaterialStateProperty.all<Color>(widget.feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
          ),
          child: Text(AppLocalizations.of(context)!.numberOfRequests(widget.feed.requests?.length ?? 0, widget.feed.requests?.length ?? 0))
      );
    } else if (_isAuthor()) {
      return const SizedBox.shrink();
    } else if (_isSubscribed()) {
      return IconButton(
          onPressed: _unsubscribeFromFeed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: MaterialStateProperty.all<double>(0),
              textStyle: MaterialStateProperty.all<TextStyle>(Theme.of(context).textTheme.bodyMedium!),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.errorContainer),
              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onErrorContainer)
          ),
          icon: const Icon(SolarIconsBold.homeAngle)
      );
    } else if (_isPrivate() && !_isRequested()) {
      return IconButton(
          onPressed: _requestToJoinFeed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: MaterialStateProperty.all<double>(0),
              textStyle: MaterialStateProperty.all<TextStyle>(Theme.of(context).textTheme.bodyMedium!),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: MaterialStateProperty.all<Color>(widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: MaterialStateProperty.all<Color>(widget.feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
          ),
          icon: const Icon(SolarIconsOutline.lockKeyholeMinimalistic)
      );
    } else if (_isPrivate() && _isRequested()) {
      return ElevatedButton(
          onPressed: null,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: MaterialStateProperty.all<double>(0),
              textStyle: MaterialStateProperty.all<TextStyle>(Theme.of(context).textTheme.bodyMedium!),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: MaterialStateProperty.all<Color>(widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: MaterialStateProperty.all<Color>(widget.feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
          ),
          child: Text(AppLocalizations.of(context)!.requested)
      );
    } else {
      return IconButton(
          onPressed: _subscribeToFeed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              elevation: MaterialStateProperty.all<double>(0),
              textStyle: MaterialStateProperty.all<TextStyle>(Theme.of(context).textTheme.bodyMedium!),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16)),
              backgroundColor: MaterialStateProperty.all<Color>(widget.feed.color ?? Theme.of(context).primaryColor),
              foregroundColor: MaterialStateProperty.all<Color>(widget.feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
          ),
          icon: const Icon(SolarIconsOutline.homeAddAngle)
      );
    }
  }
}
