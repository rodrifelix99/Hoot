import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';

class FollowButton extends StatefulWidget {
  String userId;
  bool isFollowing;
  FollowButton({super.key, this.userId = '', this.isFollowing = false});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    if (widget.userId.isEmpty) {
      _isFollowing = widget.isFollowing;
      _isLoading = false;
    } else {
      _checkIfFollowing();
    }
    super.initState();
  }

  Future _checkIfFollowing() async {
    bool isFollowing = await Provider.of<AuthProvider>(context, listen: false).isFollowing(widget.userId);
    setState(() {
      _isLoading = false;
      _isFollowing = isFollowing;
    });
  }

  Future _follow() async {
    setState(() {
      _isFollowing = true;
    });
    bool res = await Provider.of<AuthProvider>(context, listen: false).follow(widget.userId);
    if (!res) {
      setState(() {
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
        _isFollowing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
      onPressed: _isFollowing ? _unfollow : _follow,
      child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
