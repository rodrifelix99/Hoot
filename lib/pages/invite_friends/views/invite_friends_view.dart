import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hoot/pages/invite_friends/controllers/invite_friends_controller.dart';

class InviteFriendsView extends GetView<InviteFriendsController> {
  const InviteFriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('inviteFriends'.tr),
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('yourInviteCode'.tr),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      controller.inviteCode.value,
                      key: const Key('inviteCode'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: controller.inviteCode.value));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share(controller.inviteCode.value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'invitesLeftThisMonth'.trParams({
                  'count': controller.remainingInvites.value.toString(),
                }),
                key: const Key('invitesLeft'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
