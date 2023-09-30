import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skeletons/skeletons.dart';

class NativeAdComponent extends StatefulWidget {
  const NativeAdComponent({super.key});

  @override
  State<NativeAdComponent> createState() => _NativeAdComponentState();
}

class _NativeAdComponentState extends State<NativeAdComponent> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  bool _hideAd = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-2440287554514413/2948060210'
      : 'ca-app-pub-2440287554514413/5737875082';

  void loadAd() {
    _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
            print(error);
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: Theme.of(context).colorScheme.background,
            cornerRadius: 20.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Theme.of(context).colorScheme.primary,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Theme.of(context).colorScheme.onBackground,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                size: 16.0)))
      ..load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if platform is android or ios
      if (Platform.isAndroid || Platform.isIOS) {
        loadAd();
      } else {
        _hideAd = true;
      }
    });
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hideAd ? const SizedBox.shrink() : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.sponsored,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.ethicalAdDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 320,
              maxWidth: 400,
              maxHeight: 400,
            ),
            child: Skeleton(
              isLoading: _nativeAdIsLoaded == false || _nativeAd == null,
              skeleton: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _nativeAd != null ? AdWidget(ad: _nativeAd!) : const SizedBox.shrink(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppLocalizations.of(context)!.thankYouForSupporting,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
