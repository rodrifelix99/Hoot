[![CLA assistant](https://cla-assistant.io/readme/badge/rodrifelix99/Hoot)](https://cla-assistant.io/rodrifelix99/Hoot)
# hoot

The good old social network

## Purpose and basic concept
The app greets new users with text that explains its philosophy: “Are you ready to start hooting? With Hoot there’s no rate limits, no ads and no tracking. Just you and your friends.”

## Sign‑up and onboarding
Users can sign in via Google or Apple, as shown in the login page where SignInWithGoogleButton and SignInWithAppleButton are displayed near the bottom of the screen

New users complete a multi-step welcome flow that asks for a display name, username, and profile picture. The onboarding messages invite users with phrases like “Wait! A new friend?!” and guide them with hints on acceptable usernames and avatars

## Main navigation
Once signed in, the user reaches the home page. A bottom navigation bar switches between Feeds, Explore, Create Post, Notifications, and Profile sections. A small radio player overlay is accessible from the feed, opening a page that streams music with play, pause, and next controls

## Posts and feeds
Users can create posts (“hoots”) with text up to 280 characters, images, and GIFs. The CreatePostPage shows features to pick images or GIFs, insert a link preview, and select which feed to post to

Each user may create “feeds,” which are thematic collections that others can subscribe to. When creating a feed, the user can set a title, description, color, genre, and specify if it’s private or NSFW

Private feeds generate subscription requests that the feed owner can accept or decline

## Social interactions
Users can follow one another; notifications inform them of new followers or unsubscribes, as indicated by translation keys like “newFollower” and “newUnfollower”

Feeds can be subscribed to or unsubscribed from. Notifications also cover events such as subscription requests and likes on posts
Invite owners receive a notification when someone joins using their code

## Explore and search
The Explore page highlights top feeds, new feeds, and popular feed genres. Users can search by username or browse feeds by genre using dedicated pages

## Profile and settings
Each profile displays the user’s banner, avatar, bio, and their feeds. From their profile, users can edit feeds, see subscribers, and create new posts directly via floating buttons

The settings page provides options such as dark mode toggle, editing the profile, finding friends from contacts, viewing the terms of service, deleting the account, or signing out. It also displays a personal note from the creator and app version information

## Overall flow
Hoot operates like a streamlined community platform:

- Join/Log in – through Google or Apple.

- Complete onboarding – set a display name, username, and optionally an avatar.

- Navigate – use the bottom menu to see your feed, discover content, create posts, check notifications, and manage your profile.

- Create or join feeds – organize posts by interest areas, manage privacy, and interact via subscriptions.

- Manage your account – adjust settings, handle notifications, and optionally delete the account.

- This structure delivers a classic social-network experience—connecting people through posts and feeds—with an emphasis on simplicity and user privacy.

## Installing Flutter

1. Download the [Flutter SDK](https://docs.flutter.dev/get-started/install) for your platform and extract it.
2. Add the `flutter/bin` directory to your `PATH`.
3. Verify installation with:

   ```bash
   flutter --version
   ```

## Environment configuration

Create a `.env` file based on `.env.example` and supply your own API keys. The
app loads this file at startup to configure services like Tenor.

Firebase configuration lives in `lib/firebase_options.dart`, which is excluded
from version control. Generate this file locally with the
[FlutterFire CLI](https://firebase.flutter.dev/docs/cli) or provide the
equivalent options via environment variables at runtime.

## Running Tests

Widget and model tests are located under the `test/` directory. Make sure to
run `flutter pub get` to install dependencies before executing `flutter test`.
The suite uses mocked Firebase services via the `fake_cloud_firestore` and
`firebase_auth_mocks` packages, so no emulator setup is required.

```bash
flutter pub get
flutter test
```

## Cloud Functions

The backend includes a trigger named `onAuthUserDeleted` that runs whenever a Firebase Auth user is removed. It removes the user's Firestore document along with posts, subscriptions and notifications to satisfy EU data deletion rules.

Another trigger, `onNotificationCreated`, sends a push notification via OneSignal whenever a new notification document is added for a user. Set the environment variables `ONESIGNAL_APP_ID` and `ONESIGNAL_API_KEY` in your Firebase project so this function can authenticate with the OneSignal API.

Cloud Functions are built for Node.js 22 (see `functions/package.json`). Run `npm install` inside the `functions/` directory before executing `npm run build` or `firebase deploy`.

## Contributing

Read the [contributing guidelines](CONTRIBUTING.md) for information on preferred patterns and example usage of services.


## License

This project uses the [Hoot Contributor License](LICENSE). The license permits
submitting improvements to this repository but does not grant permission to use
or redistribute the code for other purposes.
