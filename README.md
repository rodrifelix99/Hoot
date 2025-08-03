[![CLA assistant](https://cla-assistant.io/readme/badge/rodrifelix99/Hoot)](https://cla-assistant.io/rodrifelix99/Hoot)

# Hoot

Hoot is a community-first social network built with Flutter. It brings back the feel of the early web: no rate limits, no ads and no tracking—just you and your friends.

## Features
- Sign in with Google or Apple
- Multi-step onboarding to choose your name and avatar
- Create posts ("hoots") with text, images and GIFs
- Build and subscribe to thematic feeds
- Follow people and get notified about new followers, likes and mentions
- Explore popular feeds or search by username or genre
- Customize your profile and toggle dark mode

## Getting Started

### 1. Install Flutter
1. Download the [Flutter SDK](https://docs.flutter.dev/get-started/install) and add `flutter/bin` to your `PATH`.
2. Verify the installation:
   ```bash
   flutter --version
   ```

### 2. Fetch dependencies
```bash
git clone https://github.com/rodrifelix99/Hoot.git
cd Hoot
flutter pub get
```

### 3. Environment configuration
1. Copy `.env.example` to `.env` and fill in your API keys (e.g., Tenor).
2. Generate `lib/firebase_options.dart` using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) or provide equivalent options through environment variables at runtime.

### 4. Run the app
```bash
flutter run
```

### 5. Run tests
```bash
flutter test
```

## User roles

Every document in the `users` collection contains a `role` field indicating whether the account is a regular `user` or a member of `staff`. New accounts default to the `user` role. To promote someone to staff, set their document's `role` to `staff` in Firestore. To demote them, change the value back to `user`.

## Contributing

Read the [contributing guidelines](CONTRIBUTING.md) for information on preferred patterns and example usage of services.

## License

This project uses the [Hoot Contributor License](LICENSE). The license permits submitting improvements to this repository but does not grant permission to use or redistribute the code for other purposes.

