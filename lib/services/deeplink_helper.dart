import 'package:build_growth_mobile/pages/content/attendacne_listen_page.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkHelper {
  static Future<void> initUniLinks(BuildContext context) async {
    try {
      // Get the initial link
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(context, initialLink);
      }

      // Listen for future links
      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(context, uri.toString());
        }
      }, onError: (err) {
        print('Deep link error: $err');
      });
    } catch (e) {
      print('Deep link initialization error: $e');
    }
  }

  static void _handleDeepLink(BuildContext context, String link) {
    print('Received deep link: $link');
    Uri uri = Uri.parse(link);
    String? token = uri.queryParameters['token'];
    
   
    switch (uri.host) {
      case 'open':
        // Example: Navigate to a specific page
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const AttendacneListenPage()));
      //  Navigator.pushNamed(context, '/specific-page');
        break;
      // case 'action':
      //   // Handle different actions
      //   _handleSpecificAction(uri);
      //   break;
      default:
        // Default navigation or handling
        Navigator.pushNamed(context, '/home');
    }
  }

  static void _handleSpecificAction(Uri uri) {
    // Extract parameters and perform specific actions
    String? param = uri.queryParameters['param'];
    if (param != null) {
      // Do something with the parameter
      print('Received parameter: $param');
    }
  }
}
