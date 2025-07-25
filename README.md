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

## Running Tests

To execute the widget tests run:

```bash
flutter test
```

Make sure all dependencies have been fetched with `flutter pub get` before running the tests.

## License

This project is licensed under the [MIT License](LICENSE).
