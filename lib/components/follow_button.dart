import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/auth_provider.dart';

class FollowButton extends StatefulWidget {
  final String userId;
  const FollowButton({super.key, required this.userId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  Future _checkIfFollowing() async {
    bool isFollowing = await Provider.of<AuthProvider>(context, listen: false).isFollowing(widget.userId);
    setState(() {
      _isFollowing = isFollowing;
      _isLoading = false;
    });
  }

  Future _follow() async {
    setState(() {
      _isFollowing = true;
    });
    bool res = await Provider.of<AuthProvider>(context, listen: false).follow(widget.userId);
    if (!res) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorFollow)));
        _isFollowing = false;
      });
    }
  }

  Future _unfollow() async {
    setState(() {
      _isFollowing = false;
    });
    bool res = await Provider.of<AuthProvider>(context, listen: false).unfollow(widget.userId);
    if (!res) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorUnfollow)));
        _isFollowing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator())
        : ElevatedButton(
      onPressed: _isFollowing ? _unfollow : _follow,
      style: ElevatedButton.styleFrom(
        foregroundColor: _isFollowing ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary
      ),
      child: Text(_isFollowing ? AppLocalizations.of(context)!.unfollow : AppLocalizations.of(context)!.follow),
    );
  }
}
