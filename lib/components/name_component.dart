import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/models/user.dart';

class NameComponent extends StatefulWidget {
  final U user;
  final int size;
  final bool bold;
  final Color color;
  final Color? textColor;
  final bool showUsername;
  final String feedName;
  const NameComponent({super.key, required this.user, this.size = 16, this.bold = true, this.color = Colors.blue, this.showUsername = false, this.feedName = '', this.textColor});

  @override
  State<NameComponent> createState() => _NameComponentState();
}

class _NameComponentState extends State<NameComponent> {
  void _onTapVerified() {
    ToastService.showToast(context, 'verifiedUser'.tr, false);
  }

  void _onTapTester() {
    ToastService.showToast(context, 'verifiedTester'.tr, false);
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
                widget.user.name ?? widget.user.username ?? 'User',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: widget.size.toDouble(),
                  fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (widget.user.verified == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: _onTapVerified,
                  child: widget.color != Colors.blue ? Icon(
                    Icons.verified_rounded,
                    color: widget.color,
                    size: widget.size.toDouble(),
                  ) : Image.asset(
                    'assets/images/verified.gif',
                    width: widget.size.toDouble(),
                    height: widget.size.toDouble(),
                  )
                ),
              ),
            if (widget.user.tester == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: _onTapTester,
                  child: widget.color != Colors.blue ? Icon(
                    Icons.bug_report_rounded,
                    color: widget.color,
                    size: widget.size.toDouble(),
                  ) : Image.asset(
                    'assets/images/bug.gif',
                    width: widget.size.toDouble(),
                    height: widget.size.toDouble(),
                  )
                ),
              ),
          ],
        ),
        widget.showUsername ? Text(
          '@${widget.user.username}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: widget.textColor ?? Theme.of(context).textTheme.bodySmall!.color,
          )
        ) : widget.feedName.isNotEmpty ? Text(
          widget.feedName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: widget.textColor ?? Theme.of(context).textTheme.bodySmall!.color,
          )
        ) : const SizedBox(),
      ],
    );
  }
}
