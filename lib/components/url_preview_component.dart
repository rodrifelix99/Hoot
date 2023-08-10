import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:ogp_data_extract/ogp_data_extract.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UrlPreviewComponent extends StatefulWidget {
  final String url;
  final bool isClickable = true;
  const UrlPreviewComponent({super.key, required this.url, isClickable});

  @override
  State<UrlPreviewComponent> createState() => _UrlPreviewComponentState();
}

class _UrlPreviewComponentState extends State<UrlPreviewComponent> {
  late OgpData _ogp;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getOgp().then((value) => setState(() {
      _ogp = value;
      _isLoading = false;
    }));
  }

  Future<OgpData> _getOgp() async {
    return await OgpDataExtract.execute(widget.url) ?? OgpData();
  }

  Future _visitUrl() async {
    await launchUrlString(widget.url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? GestureDetector(
      onTap: widget.isClickable ? _visitUrl : null,
      child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    width: 100,
                    height: 100,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkeletonParagraph(
                          style: const SkeletonParagraphStyle(
                            lines: 1,
                            spacing: 10,
                            lineStyle: SkeletonLineStyle(
                              height: 10,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SkeletonParagraph(
                          style: const SkeletonParagraphStyle(
                            lines: 2,
                            spacing: 10,
                            lineStyle: SkeletonLineStyle(
                              height: 10,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    ) : GestureDetector(
      onTap: widget.isClickable ? _visitUrl : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: OctoImage(
                    image: NetworkImage(_ogp.image ?? "https://i.gifer.com/DXKg.gif"),
                    placeholderBuilder: OctoPlaceholder.blurHash(
                      r'LSJ?=;V[Osax0;NGs:WC~RM|$%ae',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_ogp.title ?? AppLocalizations.of(context)!.clickToViewThisWebsite, style: Theme.of(context).textTheme.bodyLarge),
                    Text(_ogp.description ?? "", style: Theme.of(context).textTheme.bodyMedium),
                    Text(_ogp.url ?? widget.url, style: Theme.of(context).textTheme.bodySmall),
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
