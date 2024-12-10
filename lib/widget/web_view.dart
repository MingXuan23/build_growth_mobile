import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWPage extends StatefulWidget {
  final String url;
  final String? header;

  const WebViewWPage({Key? key, required this.url, required this.header})
      : super(key: key);

  @override
  State<WebViewWPage> createState() => _CustomWebViewWidgetState();
}

class _CustomWebViewWidgetState extends State<WebViewWPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            print("Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        method: LoadRequestMethod.get,
        //headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      final platformController = _controller.platform;

if (platformController is AndroidWebViewController) {
  platformController.setGeolocationPermissionsPromptCallbacks(
    onShowPrompt: (request) async {
      // request location permission
      final locationPermissionStatus = await Permission.locationWhenInUse.request();
    
      // return the response
      return GeolocationPermissionsResponse(
        allow: locationPermissionStatus == PermissionStatus.granted,
        retain: false,
      );
    },
  );
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.header != null
          ? BugAppBar(widget.header ?? '', context)
          : null,
      body: WebViewWidget(controller: _controller),
      bottomNavigationBar: BugPrimaryButton(
          text: 'Back',
          onPressed: () {
            Navigator.of(context).pop();
          },
          borderRadius: 0),
    );
  }
}
