import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
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
      appBar: const AppBarComponent(
        title: 'Terms of Service',
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
