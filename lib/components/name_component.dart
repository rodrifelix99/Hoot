import 'package:flutter/material.dart';
import 'package:hoot/models/user.dart';

class NameComponent extends StatelessWidget {
  final U user;
  final int size;
  final bool bold;
  final Color color;
  final Color? textColor;
  final bool showUsername;
  final String feedName;
  const NameComponent({super.key, required this.user, this.size = 16, this.bold = true, this.color = Colors.blue, this.showUsername = false, this.feedName = '', this.textColor});

  void _onTapVerified() {
    // TODO: Implement verified user tap action to show a toast indicating the user is verified
  }

  void _onTapTester() {
    // TODO: Implement tester user tap action to show a toast indicating the user is a tester
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
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor ?? Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: size.toDouble(),
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (user.verified == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: _onTapVerified,
                  child: color != Colors.blue ? Icon(
                    Icons.verified_rounded,
                    color: color,
                    size: size.toDouble(),
                  ) : Image.asset(
                    'assets/images/verified.gif',
                    width: size.toDouble(),
                    height: size.toDouble(),
                  )
                ),
              ),
            if (user.tester == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: _onTapTester,
                  child: color != Colors.blue ? Icon(
                    Icons.bug_report_rounded,
                    color: color,
                    size: size.toDouble(),
                  ) : Image.asset(
                    'assets/images/bug.gif',
                    width: size.toDouble(),
                    height: size.toDouble(),
                  )
                ),
              ),
          ],
        ),
        showUsername ? Text(
          '@${user.username}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor ?? Theme.of(context).textTheme.bodySmall!.color,
          )
        ) : feedName.isNotEmpty ? Text(
          feedName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor ?? Theme.of(context).textTheme.bodySmall!.color,
          )
        ) : const SizedBox(),
      ],
    );
  }
}
