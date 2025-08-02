import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:ogp_data_extract/ogp_data_extract.dart';
import 'package:hoot/components/shimmer_skeletons.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:hoot/services/haptic_service.dart';

class UrlPreviewComponent extends StatefulWidget {
  final String url;
  final bool isClickable;
  const UrlPreviewComponent(
      {super.key, required this.url, this.isClickable = true});

  @override
  State<UrlPreviewComponent> createState() => _UrlPreviewComponentState();
}

class _UrlPreviewComponentState extends State<UrlPreviewComponent> {
  late OgpData _ogp;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOgp();
  }

  void _loadOgp() {
    setState(() => _isLoading = true);
    _getOgp().then((value) {
      if (!mounted) return;
      setState(() {
        _ogp = value;
        _isLoading = false;
      });
    });
  }

  @override
  void didUpdateWidget(covariant UrlPreviewComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadOgp();
    }
  }

  Future<OgpData> _getOgp() async {
    return await OgpDataExtract.execute(widget.url) ?? OgpData();
  }

  Future _visitUrl() async {
    await launchUrlString(widget.url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? GestureDetector(
            onTap: widget.isClickable
                ? () {
                    HapticService.lightImpact();
                    _visitUrl();
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(
                    width: 100,
                    height: 100,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ShimmerParagraph(
                              lines: 1, spacing: 10, height: 10),
                          const SizedBox(height: 10),
                          const ShimmerParagraph(
                              lines: 2, spacing: 10, height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: widget.isClickable
                ? () {
                    HapticService.lightImpact();
                    _visitUrl();
                  }
                : null,
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .shadow
                        .withAlpha(15),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    child: HashCachedImage(
                      imageUrl: _ogp.image ?? "https://i.gifer.com/DXKg.gif",
                      errorWidget: (context, error, stackTrace) => Icon(
                        SolarIconsBold.shieldNetwork,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      placeholder: (context) => const SizedBox.shrink(),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            _ogp.title ?? 'clickToViewThisWebsite'.tr,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            _ogp.description ?? "",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(_ogp.url ?? widget.url,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.5),
                                  )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
