import 'dart:math';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/services/location_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/web_view.dart';
import 'package:flutter/material.dart';

class PlaceSelectionPage extends StatefulWidget {
  const PlaceSelectionPage({super.key});

  @override
  _ShufflePageState createState() => _ShufflePageState();
}

class _ShufflePageState extends State<PlaceSelectionPage> {
  String? selected_place;
  final List<String> _budgetPlaces = [
    "Pusat Pengagihan Makanan Percuma",
    "Pusat Zakat",
    "Stesen Minyak",
    "Pasar Malam",
    "Pasar",
    "Ar-Rahnu (Pajak Gadai)",
    "Klinik Satu Malaysia",

    "Cawangan Parti Politik",
    "Makanan Murah",
    "Tabung Haji",
    "ATM",

    "Bank",
    "Surau",

    "Bus Station",
    "Bus Stop",
    "Pusat Komuniti",
    "Balai Raya",
    "Balai Polis",
    "Pusat Kesihatan Awam",
    "Kedai Runcit",
    "Pejabat Kerajaan",

    "Kedai Koperasi",
    "Perpustakaan",
    "Masjid",
    "Pusat Khidmat Masyarakat",

    "Perkhidmatan Kaunseling Awam",

    "Pasar Barang Terpakai",
    "Pusat Pembangunan Kemahiran",
    "Kebajikan Masyarakat",

    // English
    "Affordable Restaurant",

    "Pawn Shop",

    "Baitulmal",

    "Political Party Branch",
    "Pos Malaysia Branch",
    "Clinic",
    "Community Center",
    "Police Station",
    "Free Food Distribution Center",
    "Free Parking",
    "Fuel Station",
    "Grocery",
    "Government Office",
    "Hospital",
    "Library",
    "Mosque",
    "Park",
    "Community Service Center",
    "Public Counseling Service",
    "Public Health Center",
    "PTPTN Office",
    "Recycling Center",
    "Social Welfare",
    "Soup Kitchen",
    "Thrift Store",
    "Vocational Training Center",
  ];

  List<String> _displayedPlaces = [];

  @override
  void initState() {
    super.initState();
    _displayedPlaces =
        _budgetPlaces.take(15).toList(); // Initially show the first 15
  }

  void _shufflePlaces() {
    setState(() {
      _displayedPlaces = (_budgetPlaces..shuffle())
          .take(15)
          .toList(); // Shuffle and display 15 random places
    });

    // Print the names of the places
    _displayedPlaces.forEach((place) {
      print(place);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BugAppBar('Budget Places To Go', context, show_icon: false),
      body: (selected_place != null)
          ? WebViewWPage(
              url:
                  'https://www.google.com/maps/search/?api=1&query=${selected_place ?? ''}',
              header: null)
          : Padding(
              padding: EdgeInsets.all(ResStyle.spacing),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: ResStyle.spacing /
                            2, // Horizontal space between buttons
                        runSpacing: ResStyle.spacing /
                            2, // Vertical space between lines of buttons
                        children: _displayedPlaces.map((place) {
                          return BugSmallButton(
                            text: place,
                            font_size: ResStyle.medium_font,
                            color: TITLE_COLOR,
                            onPressed: () async {
                              selected_place = place;
                              setState(() {});
                              await LocationHelper.getAddress();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  BugPrimaryButton(
                      text: 'Find More',
                      onPressed: _shufflePlaces,
                      color: RM50_COLOR),
                ],
              ),
            ),
    );
  }
}
