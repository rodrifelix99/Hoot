# Contributing Guidelines

Thank you for helping improve Hoot! This document summarizes the preferred development patterns.

## State management

- Use **GetX** for controllers and dependency injection.
- Expose values as `Rx` whenever possible so widgets can reactively update via `Obx`.
- Prefer small controllers that focus on loading data and exposing observable values.

## Streams and subscriptions

- Start listening to streams in `onInit` and cancel them in `onClose`.
- Use the provided subscription services rather than creating ad‑hoc streams.
- Avoid holding `StreamSubscription` objects outside of the controller lifecycle.

## Example

Below is a simplified controller that listens to `AuthService.currentUser` and loads the feeds the user is subscribed to using the centralized `SubscriptionService`.

```dart
class MySubsController extends GetxController {
  final AuthService _authService;
  final SubscriptionService _subscriptionService;

  MySubsController({
    AuthService? authService,
    SubscriptionService? subscriptionService,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>();

  final RxList<Feed> feeds = <Feed>[].obs;
  StreamSubscription<U?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _authSub = _authService.currentUserStream.listen((user) async {
      if (user != null) {
        final result =
            await _subscriptionService.fetchSubscribedFeeds(user.uid);
        feeds.assignAll(result);
      } else {
        feeds.clear();
      }
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }
}
```

Following these patterns keeps controllers predictable and ensures subscriptions are cleaned up correctly.

