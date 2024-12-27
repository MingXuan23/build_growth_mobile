import 'package:build_growth_mobile/models/card.dart';
import 'package:build_growth_mobile/services/emv_card_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

 // Your EmvCardReader class

class EmvCardReaderPage extends StatefulWidget {
  @override
  _EmvCardReaderPageState createState() => _EmvCardReaderPageState();
}

class _EmvCardReaderPageState extends State<EmvCardReaderPage> {
  bool _nfcAvailable = false;
  bool _isReading = false;
  EmvCard? _emvCard;
  final EmvCardReader emv_card_reader = EmvCardReader();
  StreamSubscription<EmvCard?>? _subscription;

  @override
  void initState() {
    super.initState();
    checkNfcAvailability();
  }

  Future<void> checkNfcAvailability() async {
    bool available = await EmvCardReader.available();
   
    setState(() {
      _nfcAvailable = available;
    });
  }

  Future<void> checkNFCSetting() async{
    await EmvCardReader.openNFCSetting(context);
     await showDialog<void>(
            context: context,
            barrierDismissible: false, // User must tap button to dismiss
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('NFC Settings'),
                content: const Text('NFC Setting need to enable to use this feature'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Refresh'),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      await checkNfcAvailability(); // Check NFC availability again
                    },
                  ),
                ],
              );
            },
          );
  }


  Future<void> startReading() async {
    setState(() {
      _isReading = true;
    });

    // Start the NFC reader and listen for EMV card data
    bool started = await emv_card_reader.start();
    if (started) {
      // Start listening to the stream
      _subscription = emv_card_reader.stream().listen((EmvCard? card) {
        setState(() {
          _emvCard = card;
          _isReading = false;
        });
      }, onError: (error) {
        setState(() {
          _isReading = false;
        });
        print('Error reading card: $error');
      });
    }
  }

  Future<void> stopReading() async {
    await emv_card_reader.stop();
    _subscription?.cancel();
    setState(() {
      _isReading = false;
      _emvCard = null;
    });
  }

  @override
  void dispose() {
    stopReading();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Card Reader'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _nfcAvailable
                  ? Column(
                      children: [
                        _isReading
                            ? CircularProgressIndicator()
                            : _emvCard != null
                                ? Column(
                                    children: [
                                      Text('Card Number: ${_emvCard!.number ?? "Unknown"}'),
                                      Text('Card Type: ${_emvCard!.type ?? "Unknown"}'),
                                      Text('Card Holder: ${_emvCard!.holder ?? "Unknown"}'),
                                      Text('Expiry Date: ${_emvCard!.expire ?? "Unknown"}'),
                                      Text('Status: ${_emvCard!.status ?? "Unknown"}'),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: stopReading,
                                        child: Text('Stop Reading'),
                                      ),
                                    ],
                                  )
                                : ElevatedButton(
                                    onPressed: startReading,
                                    child: Text('Start Reading'),
                                  ),
                      ],
                    )
                  : Column(children: [
                        Text('NFC is not available on this device'),
                        ElevatedButton(onPressed: checkNFCSetting, child: Text("Enable NFC Now"))
                  ],) 
            ],
          ),
        ),
      ),
    );
  }
}
