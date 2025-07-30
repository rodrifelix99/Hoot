import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/haptic_service.dart';

class NameComponent extends StatelessWidget {
  final U user;
  final int size;
  final bool bold;
  final Color color;
  final Color? textColor;
  final bool showUsername;
  final String feedName;
  final TextAlign? textAlign;

  const NameComponent({
    super.key,
    required this.user,
    this.size = 16,
    this.bold = true,
    this.color = Colors.blue,
    this.showUsername = false,
    this.feedName = '',
    this.textColor,
    this.textAlign,
  });

  void _onTapVerified() {
    ToastService.showInfo('verifiedUser'.tr);
  }

  void _onTapTester() {
    ToastService.showInfo('verifiedTester'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.4,
              ),
              child: Text(
                user.name ?? user.username ?? 'User',
                textAlign: textAlign ?? TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      textColor ?? Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: size.toDouble(),
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (user.verified == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                    onTap: () {
                      HapticService.lightImpact();
                      _onTapVerified();
                    },
                    child: color != Colors.blue
                        ? Icon(
                            Icons.verified_rounded,
                            color: color,
                            size: size.toDouble(),
                          )
                        : Image.asset(
                            'assets/images/verified.gif',
                            width: size.toDouble(),
                            height: size.toDouble(),
                          )),
              ),
            if (user.tester == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                    onTap: () {
                      HapticService.lightImpact();
                      _onTapTester();
                    },
                    child: color != Colors.blue
                        ? Icon(
                            Icons.bug_report_rounded,
                            color: color,
                            size: size.toDouble(),
                          )
                        : Image.asset(
                            'assets/images/bug.gif',
                            width: size.toDouble(),
                            height: size.toDouble(),
                          )),
              ),
          ],
        ),
        showUsername
            ? Text('@${user.username}',
                textAlign: textAlign ?? TextAlign.start,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor ??
                          Theme.of(context).textTheme.bodySmall!.color,
                    ))
            : feedName.isNotEmpty
                ? Text(feedName,
                    textAlign: textAlign ?? TextAlign.start,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor ??
                              Theme.of(context).textTheme.bodySmall!.color,
                        ))
                : const SizedBox(),
      ],
    );
  }
}
