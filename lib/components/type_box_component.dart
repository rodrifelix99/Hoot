import 'package:flutter/material.dart';
import 'package:hoot/models/feed_types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skeletons/skeletons.dart';

class TypeBoxComponent extends StatefulWidget {
  final FeedType type;
  final bool isLast;
  final bool isSkeleton;
  const TypeBoxComponent({super.key, required this.type, this.isLast = false, this.isSkeleton = false});

  @override
  State<TypeBoxComponent> createState() => _TypeBoxComponentState();
}

class _TypeBoxComponentState extends State<TypeBoxComponent> {
  late Color color;

  @override
  void initState() {
    color = Colors.primaries[widget.type.index % Colors.primaries.length];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: widget.isSkeleton ? Skeleton(
          isLoading: widget.isSkeleton,
          skeleton: Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.6),
                  color.withOpacity(0.9),
                ],
              ),
            ),
          ),
          child: Container(),
      ) : Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.6),
              color.withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: -25,
              child: Icon(
                widget.isLast ? Icons.more_vert_rounded : FeedTypeExtension.toIcon(widget.type),
                color: Colors.white.withOpacity(0.2),
                size: 150,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 15,
              child: SizedBox(
                width: 150,
                child: Text(
                  widget.isLast ? AppLocalizations.of(context)!.discoverMoreFeeds : FeedTypeExtension.toTranslatedString(context, widget.type),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    // make fontSize adaptive to screen size
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
