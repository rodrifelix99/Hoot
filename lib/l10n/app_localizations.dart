import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hoot'**
  String get welcome;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Hoot'**
  String get appName;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you ready to start hooting? With Hoot there\'s no rate limits, no ads and no tracking. Just you and your friends.'**
  String get welcomeDescription;

  /// No description provided for @displayNameExample.
  ///
  /// In en, this message translates to:
  /// **'This is your display name, eg.: Captain Felix'**
  String get displayNameExample;

  /// No description provided for @waitANewFriend.
  ///
  /// In en, this message translates to:
  /// **'Wait! A new friend?!'**
  String get waitANewFriend;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @displayNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Your name must be at least 3 characters long'**
  String get displayNameTooShort;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneNumberInvalid;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidVerificationCode;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 6 characters long'**
  String get passwordTooShort;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get repeatPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createMyAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @bySigningUpYouAgreeToOur.
  ///
  /// In en, this message translates to:
  /// **'By signing in you agree to our'**
  String get bySigningUpYouAgreeToOur;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service and Privacy Policy'**
  String get termsOfService;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get signInFailed;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get errorWeakPassword;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'User disabled'**
  String get userDisabled;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get errorWrongPassword;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email or password incorrect'**
  String get errorUserNotFound;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get errorUnknown;

  /// No description provided for @whatsYourName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get whatsYourName;

  /// No description provided for @displayNameDescription.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hoot, the world of Feeds awaits you! But first, what should we call you?'**
  String get displayNameDescription;

  /// No description provided for @letsSpiceItUp.
  ///
  /// In en, this message translates to:
  /// **'Let\'s spice it up!'**
  String get letsSpiceItUp;

  /// No description provided for @usernameDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell us what username you’d like to use. Remember: usernames can only have letters, numbers and underscores.'**
  String get usernameDescription;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'@username'**
  String get username;

  /// No description provided for @usernameExample.
  ///
  /// In en, this message translates to:
  /// **'This is your username, eg.: @captainFelix_8167'**
  String get usernameExample;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get usernameTaken;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Your username must be at least 6 characters long'**
  String get usernameTooShort;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Your username can only contain letters, numbers and underscores'**
  String get usernameInvalid;

  /// No description provided for @pressEnterToContinue.
  ///
  /// In en, this message translates to:
  /// **'Press enter to continue'**
  String get pressEnterToContinue;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @profilePictureDescription.
  ///
  /// In en, this message translates to:
  /// **'You can select an avatar for your profile. Anything is welcome: your beautiful face, your dog, that sunset pic you took yesterday, etc.'**
  String get profilePictureDescription;

  /// No description provided for @avatarSelectedFunny1.
  ///
  /// In en, this message translates to:
  /// **'Oh wow, that\'s a great choice!'**
  String get avatarSelectedFunny1;

  /// No description provided for @avatarSelectedFunny2.
  ///
  /// In en, this message translates to:
  /// **'Now that\'s a good looking owl!'**
  String get avatarSelectedFunny2;

  /// No description provided for @avatarSelectedFunny3.
  ///
  /// In en, this message translates to:
  /// **'What a great choice!'**
  String get avatarSelectedFunny3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @myFeeds.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get myFeeds;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @errorFollow.
  ///
  /// In en, this message translates to:
  /// **'Error following user'**
  String get errorFollow;

  /// No description provided for @errorUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Error unfollowing user'**
  String get errorUnfollow;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Make a Hoot'**
  String get createPost;

  /// No description provided for @postPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get postPlaceholder;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again later'**
  String get somethingWentWrong;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large, please choose a smaller one'**
  String get imageTooLarge;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @errorEditingProfile.
  ///
  /// In en, this message translates to:
  /// **'There was an error editing your profile'**
  String get errorEditingProfile;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by @username'**
  String get searchPlaceholder;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @noUsersToShow.
  ///
  /// In en, this message translates to:
  /// **'No users to show'**
  String get noUsersToShow;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications yet'**
  String get noNotifications;

  /// No description provided for @newFollower.
  ///
  /// In en, this message translates to:
  /// **'@{username} started following you'**
  String newFollower(Object username);

  /// No description provided for @newUnfollower.
  ///
  /// In en, this message translates to:
  /// **'@{username} unfollowed you'**
  String newUnfollower(Object username);

  /// No description provided for @createFeed.
  ///
  /// In en, this message translates to:
  /// **'Create a new Feed'**
  String get createFeed;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noFeeds.
  ///
  /// In en, this message translates to:
  /// **'{username} has no feeds yet'**
  String noFeeds(Object username);

  /// No description provided for @noFeedsYou.
  ///
  /// In en, this message translates to:
  /// **'You have no feeds yet!'**
  String get noFeedsYou;

  /// No description provided for @createFeedMessage.
  ///
  /// In en, this message translates to:
  /// **'You can create a new feed by clicking the + button'**
  String get createFeedMessage;

  /// No description provided for @newSubscriber.
  ///
  /// In en, this message translates to:
  /// **'@{username} subscribed to {feedName}'**
  String newSubscriber(Object feedName, Object username);

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @unsubscribeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unsubscribe from this feed?'**
  String get unsubscribeConfirmation;

  /// No description provided for @errorUnsubscribing.
  ///
  /// In en, this message translates to:
  /// **'There was an error unsubscribing from this feed'**
  String get errorUnsubscribing;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to subscribe to this feed?'**
  String get subscribeConfirmation;

  /// No description provided for @errorSubscribing.
  ///
  /// In en, this message translates to:
  /// **'There was an error subscribing to this feed'**
  String get errorSubscribing;

  /// No description provided for @requestToJoin.
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get requestToJoin;

  /// No description provided for @requestToJoinConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to request to join this feed?'**
  String get requestToJoinConfirmation;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @numberOfRequests.
  ///
  /// In en, this message translates to:
  /// **'{numberOfRequests, plural, =0 {No requests} one {# request} other {# requests}}'**
  String numberOfRequests(num numberOfRequests);

  /// No description provided for @errorRequestingToJoin.
  ///
  /// In en, this message translates to:
  /// **'There was an error requesting to join this feed'**
  String get errorRequestingToJoin;

  /// No description provided for @editFeed.
  ///
  /// In en, this message translates to:
  /// **'Edit Feed'**
  String get editFeed;

  /// No description provided for @unsubscriber.
  ///
  /// In en, this message translates to:
  /// **' @{username} unsubscribed from {feedName}'**
  String unsubscriber(Object feedName, Object username);

  /// No description provided for @privateFeedRequest.
  ///
  /// In en, this message translates to:
  /// **'@{username} requested to join {feedName}'**
  String privateFeedRequest(Object feedName, Object username);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @numberOfSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No subscriptions} one {1 subscription} other {{count} subscriptions}}'**
  String numberOfSubscriptions(num count);

  /// No description provided for @numberOfSubscribers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No subscribers} one {1 subscriber} other {{count} subscribers}}'**
  String numberOfSubscribers(num count);

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get by;

  /// No description provided for @deleteFeed.
  ///
  /// In en, this message translates to:
  /// **'Delete Feed'**
  String get deleteFeed;

  /// No description provided for @deleteFeedConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this feed?'**
  String get deleteFeedConfirmation;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @topFeeds.
  ///
  /// In en, this message translates to:
  /// **'Top Feeds'**
  String get topFeeds;

  /// No description provided for @noHoots.
  ///
  /// In en, this message translates to:
  /// **'No hoots to show'**
  String get noHoots;

  /// No description provided for @subscribeToSeeHoots.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to some feeds to see hoots here'**
  String get subscribeToSeeHoots;

  /// No description provided for @top10MostSubscribed.
  ///
  /// In en, this message translates to:
  /// **'Top 10 most subscribed feeds'**
  String get top10MostSubscribed;

  /// No description provided for @upAndComing.
  ///
  /// In en, this message translates to:
  /// **'Up and coming feeds'**
  String get upAndComing;

  /// No description provided for @upAndComingDescription.
  ///
  /// In en, this message translates to:
  /// **'Recent feeds that are gaining popularity'**
  String get upAndComingDescription;

  /// No description provided for @noteToUser.
  ///
  /// In en, this message translates to:
  /// **'Note to {displayName}'**
  String noteToUser(Object displayName);

  /// No description provided for @noteToUserDetails.
  ///
  /// In en, this message translates to:
  /// **'Hoot is a place to explore one\'s creativity and identity. We encourage you to be yourself and express your creativity. Be it through feeds, hoots, comments, or anything else.\n\nThere\'s no contest to be the best or the most popular. There\'s no need to be the most subscribed feed or the most liked hoot. There\'s no need to be the most followed user or the most commented hoot.\n\nYour experience is what you make of it and most of all, your people are ready to subscribe to you because your content is unique and so are you.\n\nBig hugs,\nThe Hoot Team'**
  String get noteToUserDetails;

  /// No description provided for @emptyFeed.
  ///
  /// In en, this message translates to:
  /// **'This feed is empty'**
  String get emptyFeed;

  /// No description provided for @emptyFeedDescription.
  ///
  /// In en, this message translates to:
  /// **'This feed is empty because it has no hoots. You can create a new hoot by clicking the floating button at the bottom right corner of the screen.'**
  String get emptyFeedDescription;

  /// No description provided for @emptyFeedToOtherUsers.
  ///
  /// In en, this message translates to:
  /// **'Give {displayName} some love to motivate them to hoot more!'**
  String emptyFeedToOtherUsers(Object displayName);

  /// No description provided for @thisFeedIsPrivate.
  ///
  /// In en, this message translates to:
  /// **'This feed is private'**
  String get thisFeedIsPrivate;

  /// No description provided for @onlyMembersCanSee.
  ///
  /// In en, this message translates to:
  /// **'Only people {displayName} accepts will be able to see their posts here!'**
  String onlyMembersCanSee(Object displayName);

  /// No description provided for @privateFeed.
  ///
  /// In en, this message translates to:
  /// **'Private Feed'**
  String get privateFeed;

  /// No description provided for @nsfwFeed.
  ///
  /// In en, this message translates to:
  /// **'NSFW Feed'**
  String get nsfwFeed;

  /// No description provided for @verifiedUser.
  ///
  /// In en, this message translates to:
  /// **'This user is verified'**
  String get verifiedUser;

  /// No description provided for @verifiedTester.
  ///
  /// In en, this message translates to:
  /// **'This user is a verified tester'**
  String get verifiedTester;

  /// No description provided for @youAreGoingTooFast.
  ///
  /// In en, this message translates to:
  /// **'You\'re going too fast, let\'s slow down a bit'**
  String get youAreGoingTooFast;

  /// No description provided for @newLike.
  ///
  /// In en, this message translates to:
  /// **'New Like'**
  String get newLike;

  /// No description provided for @newComment.
  ///
  /// In en, this message translates to:
  /// **'New Comment'**
  String get newComment;

  /// No description provided for @newReHoot.
  ///
  /// In en, this message translates to:
  /// **'New ReHoot'**
  String get newReHoot;

  /// No description provided for @newMention.
  ///
  /// In en, this message translates to:
  /// **'New Mention'**
  String get newMention;

  /// No description provided for @deleteOnRefeededPost.
  ///
  /// In en, this message translates to:
  /// **'To delete, do this on the hoot created when reFeeded'**
  String get deleteOnRefeededPost;

  /// No description provided for @youNeedToCreateAFeedFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to create a feed first'**
  String get youNeedToCreateAFeedFirst;

  /// No description provided for @selectAFeedToRefeedTo.
  ///
  /// In en, this message translates to:
  /// **'Select a feed to reFeed to'**
  String get selectAFeedToRefeedTo;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @activism.
  ///
  /// In en, this message translates to:
  /// **'Activism'**
  String get activism;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @adultContent.
  ///
  /// In en, this message translates to:
  /// **'Adult Content'**
  String get adultContent;

  /// No description provided for @art.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get art;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// No description provided for @celebrities.
  ///
  /// In en, this message translates to:
  /// **'Celebrities'**
  String get celebrities;

  /// No description provided for @comedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get comedy;

  /// No description provided for @design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @gaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gaming;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @inspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get inspiration;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @lgbtQ.
  ///
  /// In en, this message translates to:
  /// **'LGBTQ'**
  String get lgbtQ;

  /// No description provided for @marketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketing;

  /// No description provided for @movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @outdoors.
  ///
  /// In en, this message translates to:
  /// **'Outdoors'**
  String get outdoors;

  /// No description provided for @parenting.
  ///
  /// In en, this message translates to:
  /// **'Parenting'**
  String get parenting;

  /// No description provided for @quotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// No description provided for @relationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get relationships;

  /// No description provided for @selfImprovement.
  ///
  /// In en, this message translates to:
  /// **'Self-Improvement'**
  String get selfImprovement;

  /// No description provided for @series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get series;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @tv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get tv;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @wellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get wellness;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @cooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking;

  /// No description provided for @diY.
  ///
  /// In en, this message translates to:
  /// **'DIY'**
  String get diY;

  /// No description provided for @economics.
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get economics;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @entrepreneurship.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneurship'**
  String get entrepreneurship;

  /// No description provided for @fashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get fashion;

  /// No description provided for @gardening.
  ///
  /// In en, this message translates to:
  /// **'Gardening'**
  String get gardening;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @investing.
  ///
  /// In en, this message translates to:
  /// **'Investing'**
  String get investing;

  /// No description provided for @journalism.
  ///
  /// In en, this message translates to:
  /// **'Journalism'**
  String get journalism;

  /// No description provided for @kids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// No description provided for @literature.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get literature;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @onlineCourses.
  ///
  /// In en, this message translates to:
  /// **'Online Courses'**
  String get onlineCourses;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @photography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get photography;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @urbanExploration.
  ///
  /// In en, this message translates to:
  /// **'Urban Exploration'**
  String get urbanExploration;

  /// No description provided for @virtualReality.
  ///
  /// In en, this message translates to:
  /// **'Virtual Reality'**
  String get virtualReality;

  /// No description provided for @writing.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get writing;

  /// No description provided for @zoology.
  ///
  /// In en, this message translates to:
  /// **'Zoology'**
  String get zoology;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @popularTypes.
  ///
  /// In en, this message translates to:
  /// **'Popular feed genres'**
  String get popularTypes;

  /// No description provided for @popularTypesDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a look at the most popular feed genres'**
  String get popularTypesDescription;

  /// No description provided for @searchForGenreFeeds.
  ///
  /// In en, this message translates to:
  /// **'{genre} feeds'**
  String searchForGenreFeeds(Object genre);

  /// No description provided for @discoverMoreFeeds.
  ///
  /// In en, this message translates to:
  /// **'Discover more feeds'**
  String get discoverMoreFeeds;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @betterKnownForFeed.
  ///
  /// In en, this message translates to:
  /// **'Better known for creating {feedName}'**
  String betterKnownForFeed(Object feedName);

  /// No description provided for @reportUsername.
  ///
  /// In en, this message translates to:
  /// **'Report @{username}'**
  String reportUsername(Object username);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @syncedWithSystem.
  ///
  /// In en, this message translates to:
  /// **'Synced with system'**
  String get syncedWithSystem;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'This will delete your account and all your data. This action is irreversible.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get deleteAccountFailed;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deleteAccountSuccess;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block @{username}'**
  String blockUser(Object username);

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock @{username}'**
  String unblockUser(Object username);

  /// No description provided for @blockUserDescription.
  ///
  /// In en, this message translates to:
  /// **'This will block @{username} and they won\'t be able to see your posts or interact with you.'**
  String blockUserDescription(Object username);

  /// No description provided for @aboutYourData.
  ///
  /// In en, this message translates to:
  /// **'About Your Data'**
  String get aboutYourData;

  /// No description provided for @aboutYourDataTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your phone number is a must'**
  String get aboutYourDataTitle1;

  /// No description provided for @aboutYourDataDescription1.
  ///
  /// In en, this message translates to:
  /// **'We need your phone number to verify your identity and to keep your account secure.'**
  String get aboutYourDataDescription1;

  /// No description provided for @aboutYourDataTitle2.
  ///
  /// In en, this message translates to:
  /// **'But, is it safe?'**
  String get aboutYourDataTitle2;

  /// No description provided for @aboutYourDataDescription2.
  ///
  /// In en, this message translates to:
  /// **'We use the latest security technology to keep your authentication data safe.'**
  String get aboutYourDataDescription2;

  /// No description provided for @aboutYourDataTitle3.
  ///
  /// In en, this message translates to:
  /// **'We encrypt your phone number'**
  String get aboutYourDataTitle3;

  /// No description provided for @aboutYourDataDescription3.
  ///
  /// In en, this message translates to:
  /// **'We encrypt your phone number and store it securely.'**
  String get aboutYourDataDescription3;

  /// No description provided for @aboutYourDataTitle4.
  ///
  /// In en, this message translates to:
  /// **'No one can see your phone number'**
  String get aboutYourDataTitle4;

  /// No description provided for @aboutYourDataDescription4.
  ///
  /// In en, this message translates to:
  /// **'No one can see your phone number, not even us, it\'s all encrypted.'**
  String get aboutYourDataDescription4;

  /// No description provided for @aboutYourDataTitle5.
  ///
  /// In en, this message translates to:
  /// **'Your data is private'**
  String get aboutYourDataTitle5;

  /// No description provided for @aboutYourDataDescription5.
  ///
  /// In en, this message translates to:
  /// **'We don\'t share your data with anyone unless you tell us to.'**
  String get aboutYourDataDescription5;

  /// No description provided for @selectFeed.
  ///
  /// In en, this message translates to:
  /// **'Select a feed to hoot to'**
  String get selectFeed;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @addSound.
  ///
  /// In en, this message translates to:
  /// **'Add Sound'**
  String get addSound;

  /// No description provided for @addMusic.
  ///
  /// In en, this message translates to:
  /// **'Add Music'**
  String get addMusic;

  /// No description provided for @addGif.
  ///
  /// In en, this message translates to:
  /// **'Add GIF'**
  String get addGif;

  /// No description provided for @onlyOneUrl.
  ///
  /// In en, this message translates to:
  /// **'We suggest you to add only one URL per hoot'**
  String get onlyOneUrl;

  /// No description provided for @clickToViewThisWebsite.
  ///
  /// In en, this message translates to:
  /// **'Click to view this website'**
  String get clickToViewThisWebsite;

  /// No description provided for @sponsored.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsored;

  /// No description provided for @ethicalAdDescription.
  ///
  /// In en, this message translates to:
  /// **'Ethical ads like this one help us keep Hoot free for everyone.'**
  String get ethicalAdDescription;

  /// No description provided for @thankYouForSupporting.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Hoot!'**
  String get thankYouForSupporting;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'We just sent you a 6 digit code for the number you provided: {phoneNumber}'**
  String codeSent(Object phoneNumber);

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Number'**
  String get changeNumber;

  /// No description provided for @thatsIt.
  ///
  /// In en, this message translates to:
  /// **'That\'s it!'**
  String get thatsIt;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @likes10RecentLabel.
  ///
  /// In en, this message translates to:
  /// **'We only show the 10 most recent likes'**
  String get likes10RecentLabel;

  /// No description provided for @hootDeletedOrDoesntExist.
  ///
  /// In en, this message translates to:
  /// **'This hoot was deleted or doesn\'t exist'**
  String get hootDeletedOrDoesntExist;

  /// No description provided for @privateFeedRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'@{username} accepted your request to see their private feed: {feedName}'**
  String privateFeedRequestAccepted(Object feedName, Object username);

  /// No description provided for @privateFeedRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'@{username} rejected your request to see their private feed: {feedName}'**
  String privateFeedRequestRejected(Object feedName, Object username);

  /// No description provided for @userLikedYourHoot.
  ///
  /// In en, this message translates to:
  /// **'@{username} liked your hoot'**
  String userLikedYourHoot(Object username);

  /// No description provided for @userReFeededYourHoot.
  ///
  /// In en, this message translates to:
  /// **'@{username} reFeeded your hoot'**
  String userReFeededYourHoot(Object username);

  /// No description provided for @hootMightBeBuggy.
  ///
  /// In en, this message translates to:
  /// **'I wanted to let you know that I created Hoot all by myself during my summer break. It was a labor of love, and I poured my heart and soul into crafting a platform that could connect people and foster community. But, being a one-person team working within a limited timeframe, there might be a few bugs or features that don\'t quite work as intended. I appreciate your patience and understanding as I iron out these kinks and make the app better. I want to emphasize that your security and the protection of your information have been my top priorities from the get-go. I\'ve implemented strong security measures to ensure your data is safe and handled with the utmost care. While I am just one person, I\'m fully dedicated to improving Hoot. I\'m committed to updating and refining the app, making it the best it can be. Your feedback and support mean the world to me, and I\'m excited to grow Hoot into something truly exceptional in the future. Thank you for being a part of this journey, and I can\'t wait for you to see how Hoot evolves and becomes even greater over time.'**
  String get hootMightBeBuggy;

  /// No description provided for @messageFromCreator.
  ///
  /// In en, this message translates to:
  /// **'Message from the creator'**
  String get messageFromCreator;

  /// No description provided for @findFriends.
  ///
  /// In en, this message translates to:
  /// **'Find Friends'**
  String get findFriends;

  /// No description provided for @findFriendsFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Find friends from your contacts list'**
  String get findFriendsFromContacts;

  /// No description provided for @contactsPermission.
  ///
  /// In en, this message translates to:
  /// **'We need your permission to access your contacts'**
  String get contactsPermission;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
