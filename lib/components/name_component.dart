import 'package:flutter/material.dart';
import 'package:hoot/services/error_service.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

import '../models/user.dart';

class NameComponent extends StatefulWidget {
  final U user;
  int size;
  bool bold;
  Color color;
  bool showUsername;
  String feedName;
  NameComponent({super.key, required this.user, this.size = 16, this.bold = true, this.color = Colors.blue, this.showUsername = false, this.feedName = ''});

  @override
  State<NameComponent> createState() => _NameComponentState();
}

class _NameComponentState extends State<NameComponent> {
  void _onTapVerified() {
    ToastService.showToast(context, 'This user is verified', false);
  }

  void _onTapTester() {
    ToastService.showToast(context, 'This user is a verified tester of Hoot', false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.user.name ?? widget.user.username ?? 'User',
              style: TextStyle(
                fontSize: widget.size.toDouble(),
                fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (widget.user.verified == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: _onTapVerified,
                  child: Icon(
                    Icons.verified_rounded,
                    color: widget.color,
                    size: widget.size.toDouble(),
                  ),
                ),
              ),
            if (widget.user.tester == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: _onTapTester,
                  child: Icon(
                    Icons.bug_report_rounded,
                    color: widget.color,
                    size: widget.size.toDouble(),
                  ),
                ),
              ),
          ],
        ),
        widget.showUsername ? Text(
          '@${widget.user.username}',
          style: Theme.of(context).textTheme.bodySmall
        ) : widget.feedName.isNotEmpty ? Text(
          widget.feedName,
          style: Theme.of(context).textTheme.bodySmall
        ) : const SizedBox(),
      ],
    );
  }
}
