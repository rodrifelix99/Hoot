import 'package:flutter/material.dart';
import 'package:hoot/components/user_suggestions.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/post_component.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Post> _posts = [];
  bool _isLoading = false;

  Future _getPosts() async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<FeedProvider>(context, listen: false).getFeed();
      setState(() {
        _posts = Provider.of<FeedProvider>(context, listen: false).feed;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      ToastService.showToast(context, e.toString(), true);
    }
  }

  @override
  void initState() {
    _getPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myFeeds),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
          child: Column(
            children: [
              const UserSuggestions(),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                child: Center(
                  child: Text(
                      'Thank you for being a tester, you\'re awesome! \n\n'
                      'My Feeds will be a page where you can see all the feeds you subscribed to. '
                      'It can be a feed created by your roommate for their aesthetic and kinda gay living room, or a feed created by your friend for their cat tips.\n\n'
                      'My goal is to make something that no other social media has done before, and I think this is it. I\'m excited to see what you think about it. '
                      'You can DM me @_felix_zinho_ on Twitter to share feedback and report bugs whenever you want\n\n'
                      'From now on you\'re a part of Hoot, the very first people to see it from a simple authentication page to a full-fledged social media. '
                      'Because of that, when Hoot is released, you\'ll have a special badge on your profile, and you\'ll be given 5 invitations to invite your friends to Hoot, '
                      'while it\'s still invite-only. \n\n'
                      'For now, there\'s not much to do, but I\'ll be adding more features regularly, so stay tuned! \n\n',
                      textAlign: TextAlign.center
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                itemBuilder: (BuildContext context, int index) {
                  return PostComponent(post: _posts[index]);
                },
              ),
            ],
          )
      ),
    );
  }
}
