import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hoot/pages/invite_friends/controllers/invite_friends_controller.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:ticket_widget/ticket_widget.dart';

class InviteFriendsView extends GetView<InviteFriendsController> {
  const InviteFriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'inviteFriends'.tr,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/top_bar.png',
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Obx(
            () => Center(
              child: TicketWidget(
                width: 350,
                height: 500,
                isCornerRounded: true,
                padding: EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'yourInviteCode'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(SolarIconsOutline.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: controller.inviteCode.value));
                          },
                        ),
                        IconButton(
                          icon: const Icon(SolarIconsOutline.share),
                          onPressed: () {
                            Share.share(controller.inviteCode.value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                    Center(
                      child: Text(
                        controller.inviteCode.value,
                        key: const Key('inviteCode'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: Text(
                        'invitesLeftThisMonth'.trParams({
                          'count': controller.remainingInvites.value.toString(),
                        }),
                        textAlign: TextAlign.center,
                        key: const Key('invitesLeft'),
                      ),
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                    Text(
                      'quickTips'.tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'inviteOnlyDescription'.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 9,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
