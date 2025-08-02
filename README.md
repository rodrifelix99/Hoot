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

## Cloud Functions

The backend includes a trigger named `onAuthUserDeleted` that runs whenever a Firebase Auth user is removed. It deletes the user's Firestore document along with posts, subscriptions and notifications to satisfy EU data deletion rules.

Another trigger, `onNotificationCreated`, sends a push notification via OneSignal whenever a new notification document is added for a user. Set `ONESIGNAL_APP_ID` and `ONESIGNAL_API_KEY` in your Firebase project so this function can authenticate with the OneSignal API.

Cloud Functions are built for Node.js 22 (see `functions/package.json`). Run `npm install` inside the `functions/` directory before executing `npm run build` or `firebase deploy`.

## Contributing

Read the [contributing guidelines](CONTRIBUTING.md) for information on preferred patterns and example usage of services.

## License

This project uses the [Hoot Contributor License](LICENSE). The license permits submitting improvements to this repository but does not grant permission to use or redistribute the code for other purposes.

