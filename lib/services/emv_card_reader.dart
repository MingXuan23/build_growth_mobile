import 'dart:async';

import 'package:build_growth_mobile/models/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class EmvCardReader {
  static const _mc = const MethodChannel('emv_card_reader_channel');

  static const _ec = const EventChannel('emv_card_reader_sink');

  static bool nfc_available = false;

  static Future<bool> available() async {
    nfc_available = await _mc.invokeMethod('available');
    return nfc_available;
  }

   Future<bool> start() async {
    return await _mc.invokeMethod('start');
  }

   Future<bool> stop() async {
    return await _mc.invokeMethod('stop');
  }

   Future<EmvCard?> read() async {
    return _mc
        .invokeMapMethod<String, String?>('read')
        .then((value) => cardCallback(value));
  }

   Stream<EmvCard?> stream() {
    final sc =
        (e) => e == null ? null : cardCallback(Map<String, String?>.from(e));

    return _ec.receiveBroadcastStream().map(sc);
  }

  /// Create card object from result
   EmvCard? cardCallback(Map<String, String?>? event) {
    if (event == null) {
      return null;
    }else if(event['number']=='-' || event['type']=='Invalid'){
      return null;
    }

    return EmvCard(
      number: event['number'],
      type: event['type'],
      holder: event['holder'],
      expire: event['expire'],
      status: event['status'],
    );
  }

  static Future<bool> openNFCSetting(BuildContext context) async {
    if (Theme.of(context).platform == TargetPlatform.android &&
        !nfc_available) {
      await const MethodChannel('com.bug.build_growth_mobile/nfc')
          .invokeMethod('openNFCSettings');
      await showDialog<void>(
          context: context,
          barrierDismissible: false, // User must tap button to dismiss
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('NFC Settings'),
              content:
                  const Text('NFC Setting need to enable to use this feature'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Refresh'),
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          });
      var status = await available();

      return status;
    }

    return false;
  }
}

//copy from mainactivity.kt
//android\app\build.gradle
//pubsec.yaml