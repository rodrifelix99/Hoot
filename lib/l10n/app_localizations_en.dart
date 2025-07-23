// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get welcome => 'Welcome to Hoot';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get appName => 'Hoot';

  @override
  String get welcomeDescription =>
      'Are you ready to start hooting? With Hoot there\'s no rate limits, no ads and no tracking. Just you and your friends.';

  @override
  String get displayNameExample =>
      'This is your display name, eg.: Captain Felix';

  @override
  String get waitANewFriend => 'Wait! A new friend?!';

  @override
  String get getStarted => 'Get Started';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameTooShort =>
      'Your name must be at least 3 characters long';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberInvalid => 'Invalid phone number';

  @override
  String get invalidVerificationCode => 'Invalid verification code';

  @override
  String get email => 'Email';

  @override
  String get emailInvalid => 'Invalid email address';

  @override
  String get password => 'Password';

  @override
  String get passwordTooShort =>
      'Your password must be at least 6 characters long';

  @override
  String get repeatPassword => 'Repeat Password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get bySigningUpYouAgreeToOur => 'By signing in you agree to our';

  @override
  String get termsOfService => 'Terms of Service and Privacy Policy';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get signInFailed => 'Sign in failed';

  @override
  String get errorInvalidEmail => 'Invalid email';

  @override
  String get errorEmailAlreadyInUse => 'Email already in use';

  @override
  String get errorWeakPassword => 'Weak password';

  @override
  String get userDisabled => 'User disabled';

  @override
  String get errorWrongPassword => 'Wrong password';

  @override
  String get errorUserNotFound => 'Email or password incorrect';

  @override
  String get errorUnknown => 'Unknown error occurred';

  @override
  String get whatsYourName => 'What\'s your name?';

  @override
  String get displayNameDescription =>
      'Welcome to Hoot, the world of Feeds awaits you! But first, what should we call you?';

  @override
  String get letsSpiceItUp => 'Let\'s spice it up!';

  @override
  String get usernameDescription =>
      'Tell us what username you’d like to use. Remember: usernames can only have letters, numbers and underscores.';

  @override
  String get username => '@username';

  @override
  String get usernameExample =>
      'This is your username, eg.: @captainFelix_8167';

  @override
  String get usernameTaken => 'Username already taken';

  @override
  String get usernameTooShort =>
      'Your username must be at least 6 characters long';

  @override
  String get usernameInvalid =>
      'Your username can only contain letters, numbers and underscores';

  @override
  String get pressEnterToContinue => 'Press enter to continue';

  @override
  String get almostThere => 'Almost there!';

  @override
  String get profilePictureDescription =>
      'You can select an avatar for your profile. Anything is welcome: your beautiful face, your dog, that sunset pic you took yesterday, etc.';

  @override
  String get avatarSelectedFunny1 => 'Oh wow, that\'s a great choice!';

  @override
  String get avatarSelectedFunny2 => 'Now that\'s a good looking owl!';

  @override
  String get avatarSelectedFunny3 => 'What a great choice!';

  @override
  String get skip => 'Skip';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get continueButton => 'Continue';

  @override
  String get feed => 'Feed';

  @override
  String get myFeeds => 'Feeds';

  @override
  String get search => 'Search';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get errorFollow => 'Error following user';

  @override
  String get errorUnfollow => 'Error unfollowing user';

  @override
  String get settings => 'Settings';

  @override
  String get createPost => 'Make a Hoot';

  @override
  String get postPlaceholder => 'What\'s on your mind?';

  @override
  String get publish => 'Publish';

  @override
  String get somethingWentWrong =>
      'Something went wrong, please try again later';

  @override
  String get imageTooLarge => 'Image too large, please choose a smaller one';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get next => 'Next';

  @override
  String get cancel => 'Cancel';

  @override
  String get bio => 'Bio';

  @override
  String get done => 'Done';

  @override
  String get errorEditingProfile => 'There was an error editing your profile';

  @override
  String get searchPlaceholder => 'Search by @username';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get noUsersToShow => 'No users to show';

  @override
  String get noNotifications => 'You have no notifications yet';

  @override
  String newFollower(Object username) {
    return '@$username started following you';
  }

  @override
  String newUnfollower(Object username) {
    return '@$username unfollowed you';
  }

  @override
  String get createFeed => 'Create a new Feed';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get noResults => 'No results';

  @override
  String noFeeds(Object username) {
    return '$username has no feeds yet';
  }

  @override
  String get noFeedsYou => 'You have no feeds yet!';

  @override
  String get createFeedMessage =>
      'You can create a new feed by clicking the + button';

  @override
  String newSubscriber(Object feedName, Object username) {
    return '@$username subscribed to $feedName';
  }

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String get unsubscribeConfirmation =>
      'Are you sure you want to unsubscribe from this feed?';

  @override
  String get errorUnsubscribing =>
      'There was an error unsubscribing from this feed';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribeConfirmation =>
      'Are you sure you want to subscribe to this feed?';

  @override
  String get errorSubscribing => 'There was an error subscribing to this feed';

  @override
  String get requestToJoin => 'Request to join';

  @override
  String get requestToJoinConfirmation =>
      'Are you sure you want to request to join this feed?';

  @override
  String get request => 'Request';

  @override
  String get requested => 'Requested';

  @override
  String numberOfRequests(num numberOfRequests) {
    String _temp0 = intl.Intl.pluralLogic(
      numberOfRequests,
      locale: localeName,
      other: '# requests',
      one: '# request',
      zero: 'No requests',
    );
    return '$_temp0';
  }

  @override
  String get errorRequestingToJoin =>
      'There was an error requesting to join this feed';

  @override
  String get editFeed => 'Edit Feed';

  @override
  String unsubscriber(Object feedName, Object username) {
    return ' @$username unsubscribed from $feedName';
  }

  @override
  String privateFeedRequest(Object feedName, Object username) {
    return '@$username requested to join $feedName';
  }

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String numberOfSubscriptions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
      zero: 'No subscriptions',
    );
    return '$_temp0';
  }

  @override
  String numberOfSubscribers(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscribers',
      one: '1 subscriber',
      zero: 'No subscribers',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get by => 'by';

  @override
  String get deleteFeed => 'Delete Feed';

  @override
  String get deleteFeedConfirmation =>
      'Are you sure you want to delete this feed?';

  @override
  String get explore => 'Explore';

  @override
  String get topFeeds => 'Top Feeds';

  @override
  String get noHoots => 'No hoots to show';

  @override
  String get subscribeToSeeHoots => 'Subscribe to some feeds to see hoots here';

  @override
  String get top10MostSubscribed => 'Top 10 most subscribed feeds';

  @override
  String get upAndComing => 'Up and coming feeds';

  @override
  String get upAndComingDescription =>
      'Recent feeds that are gaining popularity';

  @override
  String noteToUser(Object displayName) {
    return 'Note to $displayName';
  }

  @override
  String get noteToUserDetails =>
      'Hoot is a place to explore one\'s creativity and identity. We encourage you to be yourself and express your creativity. Be it through feeds, hoots, comments, or anything else.\n\nThere\'s no contest to be the best or the most popular. There\'s no need to be the most subscribed feed or the most liked hoot. There\'s no need to be the most followed user or the most commented hoot.\n\nYour experience is what you make of it and most of all, your people are ready to subscribe to you because your content is unique and so are you.\n\nBig hugs,\nThe Hoot Team';

  @override
  String get emptyFeed => 'This feed is empty';

  @override
  String get emptyFeedDescription =>
      'This feed is empty because it has no hoots. You can create a new hoot by clicking the floating button at the bottom right corner of the screen.';

  @override
  String emptyFeedToOtherUsers(Object displayName) {
    return 'Give $displayName some love to motivate them to hoot more!';
  }

  @override
  String get thisFeedIsPrivate => 'This feed is private';

  @override
  String onlyMembersCanSee(Object displayName) {
    return 'Only people $displayName accepts will be able to see their posts here!';
  }

  @override
  String get privateFeed => 'Private Feed';

  @override
  String get nsfwFeed => 'NSFW Feed';

  @override
  String get verifiedUser => 'This user is verified';

  @override
  String get verifiedTester => 'This user is a verified tester';

  @override
  String get youAreGoingTooFast =>
      'You\'re going too fast, let\'s slow down a bit';

  @override
  String get newLike => 'New Like';

  @override
  String get newComment => 'New Comment';

  @override
  String get newReHoot => 'New ReHoot';

  @override
  String get newMention => 'New Mention';

  @override
  String get deleteOnRefeededPost =>
      'To delete, do this on the hoot created when reFeeded';

  @override
  String get youNeedToCreateAFeedFirst => 'You need to create a feed first';

  @override
  String get selectAFeedToRefeedTo => 'Select a feed to reFeed to';

  @override
  String get general => 'General';

  @override
  String get activism => 'Activism';

  @override
  String get activities => 'Activities';

  @override
  String get adultContent => 'Adult Content';

  @override
  String get art => 'Art';

  @override
  String get beauty => 'Beauty';

  @override
  String get celebrities => 'Celebrities';

  @override
  String get comedy => 'Comedy';

  @override
  String get design => 'Design';

  @override
  String get environment => 'Environment';

  @override
  String get family => 'Family';

  @override
  String get fitness => 'Fitness';

  @override
  String get gaming => 'Gaming';

  @override
  String get history => 'History';

  @override
  String get inspiration => 'Inspiration';

  @override
  String get jobs => 'Jobs';

  @override
  String get lgbtQ => 'LGBTQ';

  @override
  String get marketing => 'Marketing';

  @override
  String get movies => 'Movies';

  @override
  String get nature => 'Nature';

  @override
  String get outdoors => 'Outdoors';

  @override
  String get parenting => 'Parenting';

  @override
  String get quotes => 'Quotes';

  @override
  String get relationships => 'Relationships';

  @override
  String get selfImprovement => 'Self-Improvement';

  @override
  String get series => 'Series';

  @override
  String get science => 'Science';

  @override
  String get travel => 'Travel';

  @override
  String get tv => 'TV';

  @override
  String get university => 'University';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get wellness => 'Wellness';

  @override
  String get yoga => 'Yoga';

  @override
  String get business => 'Business';

  @override
  String get cooking => 'Cooking';

  @override
  String get diY => 'DIY';

  @override
  String get economics => 'Economics';

  @override
  String get education => 'Education';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get entrepreneurship => 'Entrepreneurship';

  @override
  String get fashion => 'Fashion';

  @override
  String get gardening => 'Gardening';

  @override
  String get health => 'Health';

  @override
  String get investing => 'Investing';

  @override
  String get journalism => 'Journalism';

  @override
  String get kids => 'Kids';

  @override
  String get literature => 'Literature';

  @override
  String get music => 'Music';

  @override
  String get news => 'News';

  @override
  String get onlineCourses => 'Online Courses';

  @override
  String get pets => 'Pets';

  @override
  String get photography => 'Photography';

  @override
  String get religion => 'Religion';

  @override
  String get recipes => 'Recipes';

  @override
  String get school => 'School';

  @override
  String get sports => 'Sports';

  @override
  String get technology => 'Technology';

  @override
  String get urbanExploration => 'Urban Exploration';

  @override
  String get virtualReality => 'Virtual Reality';

  @override
  String get writing => 'Writing';

  @override
  String get zoology => 'Zoology';

  @override
  String get other => 'Other';

  @override
  String get popularTypes => 'Popular feed genres';

  @override
  String get popularTypesDescription =>
      'Take a look at the most popular feed genres';

  @override
  String searchForGenreFeeds(Object genre) {
    return '$genre feeds';
  }

  @override
  String get discoverMoreFeeds => 'Discover more feeds';

  @override
  String get popular => 'Popular';

  @override
  String betterKnownForFeed(Object feedName) {
    return 'Better known for creating $feedName';
  }

  @override
  String reportUsername(Object username) {
    return 'Report @$username';
  }

  @override
  String get delete => 'Delete';

  @override
  String get aboutUs => 'About Us';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get syncedWithSystem => 'Synced with system';

  @override
  String get version => 'Version';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDescription =>
      'This will delete your account and all your data. This action is irreversible.';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountFailed => 'Failed to delete account';

  @override
  String get deleteAccountSuccess => 'Account deleted successfully';

  @override
  String blockUser(Object username) {
    return 'Block @$username';
  }

  @override
  String unblockUser(Object username) {
    return 'Unblock @$username';
  }

  @override
  String blockUserDescription(Object username) {
    return 'This will block @$username and they won\'t be able to see your posts or interact with you.';
  }

  @override
  String get aboutYourData => 'About Your Data';

  @override
  String get aboutYourDataTitle1 => 'Your phone number is a must';

  @override
  String get aboutYourDataDescription1 =>
      'We need your phone number to verify your identity and to keep your account secure.';

  @override
  String get aboutYourDataTitle2 => 'But, is it safe?';

  @override
  String get aboutYourDataDescription2 =>
      'We use the latest security technology to keep your authentication data safe.';

  @override
  String get aboutYourDataTitle3 => 'We encrypt your phone number';

  @override
  String get aboutYourDataDescription3 =>
      'We encrypt your phone number and store it securely.';

  @override
  String get aboutYourDataTitle4 => 'No one can see your phone number';

  @override
  String get aboutYourDataDescription4 =>
      'No one can see your phone number, not even us, it\'s all encrypted.';

  @override
  String get aboutYourDataTitle5 => 'Your data is private';

  @override
  String get aboutYourDataDescription5 =>
      'We don\'t share your data with anyone unless you tell us to.';

  @override
  String get selectFeed => 'Select a feed to hoot to';

  @override
  String get addImage => 'Add Image';

  @override
  String get addVideo => 'Add Video';

  @override
  String get addSound => 'Add Sound';

  @override
  String get addMusic => 'Add Music';

  @override
  String get addGif => 'Add GIF';

  @override
  String get onlyOneUrl => 'We suggest you to add only one URL per hoot';

  @override
  String get clickToViewThisWebsite => 'Click to view this website';

  @override
  String get sponsored => 'Sponsored';

  @override
  String get ethicalAdDescription =>
      'Ethical ads like this one help us keep Hoot free for everyone.';

  @override
  String get thankYouForSupporting => 'Thank you for supporting Hoot!';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String codeSent(Object phoneNumber) {
    return 'We just sent you a 6 digit code for the number you provided: $phoneNumber';
  }

  @override
  String get enterCode => 'Enter Code';

  @override
  String get changeNumber => 'Change Number';

  @override
  String get thatsIt => 'That\'s it!';

  @override
  String get likes => 'Likes';

  @override
  String get likes10RecentLabel => 'We only show the 10 most recent likes';

  @override
  String get hootDeletedOrDoesntExist =>
      'This hoot was deleted or doesn\'t exist';

  @override
  String privateFeedRequestAccepted(Object feedName, Object username) {
    return '@$username accepted your request to see their private feed: $feedName';
  }

  @override
  String privateFeedRequestRejected(Object feedName, Object username) {
    return '@$username rejected your request to see their private feed: $feedName';
  }

  @override
  String userLikedYourHoot(Object username) {
    return '@$username liked your hoot';
  }

  @override
  String userReFeededYourHoot(Object username) {
    return '@$username reFeeded your hoot';
  }

  @override
  String get hootMightBeBuggy =>
      'I wanted to let you know that I created Hoot all by myself during my summer break. It was a labor of love, and I poured my heart and soul into crafting a platform that could connect people and foster community. But, being a one-person team working within a limited timeframe, there might be a few bugs or features that don\'t quite work as intended. I appreciate your patience and understanding as I iron out these kinks and make the app better. I want to emphasize that your security and the protection of your information have been my top priorities from the get-go. I\'ve implemented strong security measures to ensure your data is safe and handled with the utmost care. While I am just one person, I\'m fully dedicated to improving Hoot. I\'m committed to updating and refining the app, making it the best it can be. Your feedback and support mean the world to me, and I\'m excited to grow Hoot into something truly exceptional in the future. Thank you for being a part of this journey, and I can\'t wait for you to see how Hoot evolves and becomes even greater over time.';

  @override
  String get messageFromCreator => 'Message from the creator';

  @override
  String get findFriends => 'Find Friends';

  @override
  String get findFriendsFromContacts => 'Find friends from your contacts list';

  @override
  String get contactsPermission =>
      'We need your permission to access your contacts';
}
