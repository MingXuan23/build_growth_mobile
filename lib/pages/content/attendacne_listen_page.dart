import 'dart:convert';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/attendance/attendance_bloc.dart';
import 'package:build_growth_mobile/services/emv_card_reader.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendacneListenPage extends StatefulWidget {
  const AttendacneListenPage({Key? key}) : super(key: key);

  @override
  _NfcReadingPageState createState() => _NfcReadingPageState();
}

class _NfcReadingPageState extends State<AttendacneListenPage> {
  static String? link;

  bool nfc_available = false;

  @override
  void initState() {
    super.initState();
    _startNFCReading(prompt: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSubmittedState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(BugSnackBar(state.message, 5));
          Navigator.of(context).pop(state.link);
        } else if (state is AttendanceErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(BugSnackBar(state.message, 5));
              _startNFCReading();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: BugAppBar('Enroll into Event', context),
          body: Padding(
            padding: EdgeInsets.all(ResStyle.spacing * 2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: ResStyle.spacing * 2,
                  ),
                  // Card with the message
                  Expanded(
                    child: Card(
                      color: nfc_available ?RM20_COLOR.withOpacity(0.9): TITLE_COLOR,
                      elevation:
                          4, // You can adjust the elevation to change the shadow
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(ResStyle.spacing *
                            2), // Add padding inside the card
                        child: Center(
                          child: Text(
                            nfc_available? 'Place your phone at the xBUG Stand':'NFC Not Granted',
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: ResStyle.body_font, // Text size
                              fontWeight: FontWeight.bold, // Text weight
                              color: nfc_available? TITLE_COLOR:HIGHTLIGHT_COLOR, // Text color
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResStyle.spacing * 2,
                  ), // Add space between card and button

                  if (!nfc_available)
                    BugIconButton(
                        onPressed: _startNFCReading,
                        text: 'Enable NFC',
                        icon: Icons.nfc_outlined,
                        color: TITLE_COLOR,
                        text_color: HIGHTLIGHT_COLOR),

                  SizedBox(
                    height: ResStyle.height * 0.15,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startNFCReading({bool prompt = true}) async {
    try {
      nfc_available = await NfcManager.instance.isAvailable();

      if(!nfc_available &&prompt){
        await EmvCardReader.openNFCSetting(context);
           nfc_available = await NfcManager.instance.isAvailable();
      }
      setState(() {});
      //We first check if NFC is available on the device.
      if (nfc_available) {
        //If NFC is available, start an NFC session and listen for NFC tags to be discovered.
           NfcManager.instance
                .stopSession(errorMessage: 'No matching data found.');
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Process NFC tag, When an NFC tag is discovered, print its data to the console.
            var ndef = Ndef.from(tag);
            if (ndef == null || ndef.cachedMessage == null) {
              NfcManager.instance
                  .stopSession(errorMessage: 'NFC data not in NDEF format.');
              return;
            }

            // Example usage
            String nfc_id = ndef.additionalData['identifier']
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(':')
                .toUpperCase();
            ;

            //String nfc_id = utf8.decode(ndef.additionalData['identifier']);

            for (var record in ndef.cachedMessage!.records) {
              // Decode the payload and ignore the first byte (Type Name Format byte)
              String payload = utf8.decode(record.payload.sublist(1));
              print('Decoded Payload: $payload');
              link = payload;

              if (payload != null) {
                link = payload.replaceFirst(RegExp(r'^.*?/deeplink/'), '');
                BlocProvider.of<AttendanceBloc>(context)
                    .add(AttendanceSubmitEvent(nfc_id, link ?? ''));
              }

              // Check if the payload contains the specific pattern
            }

            // If no matching data found
            NfcManager.instance
                .stopSession(errorMessage: 'No matching data found.');
          },
        );
      } else {
        debugPrint('NFC not available.');
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}
