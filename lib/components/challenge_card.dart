import 'dart:async';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:hoot/models/daily_challenge.dart';
import 'package:get/get.dart';

/// Card displaying the active daily challenge.
class ChallengeCard extends StatefulWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onJoin,
    this.onViewEntries,
    this.showActions = true,
  });

  final DailyChallenge challenge;
  final VoidCallback? onJoin;
  final VoidCallback? onViewEntries;
  final bool showActions;

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = _calculateRemaining();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateRemaining() {
    final expiresAt = widget.challenge.expiresAt;
    if (expiresAt == null) return Duration.zero;
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.onPrimaryContainer,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withAlpha(25),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: HashCachedImage(
              imageUrl:
                  'https://cdn.dribbble.com/userupload/42098016/file/original-95161d967fb850a082d81e3143129a34.gif',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  _formatDuration(_remaining),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withAlpha(175),
                      ),
                ),
                const Divider(
                  height: 32,
                  thickness: 1,
                  color: Colors.white12,
                ),
                Text(
                  widget.challenge.prompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                if (widget.showActions) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onViewEntries == null
                            ? null
                            : () => widget.onViewEntries!(),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        child: Text('viewEntries'.tr),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onJoin == null
                              ? null
                              : () => widget.onJoin!(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            foregroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Text('joinChallenge'.tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).frosted(
            blur: 32,
            padding: const EdgeInsets.all(12),
            frostColor: Theme.of(context).colorScheme.primaryContainer,
            frostOpacity: 0.25,
          ),
        ],
      ),
    );
  }
}
