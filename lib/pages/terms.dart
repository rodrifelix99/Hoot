import 'package:hoot/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/pages/about_your_data.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsOfService extends StatefulWidget {
  const TermsOfService({super.key});

  @override
  State<TermsOfService> createState() => _TermsOfServiceState();
}

class _TermsOfServiceState extends State<TermsOfService> {
  late final WebViewController _controller;

  @override
  void initState() {
    _controller = WebViewController();
    _controller.loadFlutterAsset('assets/terms/terms.html');
    _controller.platform.enableZoom(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'Terms of Service',
        actions: [
          IconButton(
            icon: const Icon(SolarIconsOutline.shieldPlus),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutYourDataPage()));
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
