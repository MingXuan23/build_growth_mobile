import 'dart:async';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/card.dart';
import 'package:build_growth_mobile/models/emv_card_reader.dart';
import 'package:build_growth_mobile/pages/financial/transaction_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AssetDetailPage extends StatefulWidget {
  const AssetDetailPage({super.key});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage>
    with SingleTickerProviderStateMixin {
  // ====== VARIABLES ======
  List<Asset> assets = [];
  bool NFC_status = false;
  bool NFC_reading = false;
  final EmvCardReader card_reader = EmvCardReader();
  final List<String> assetTypes = [
    'Cash',
    'Bank Card',
    'Property',
    'Stock',
    'Digital Asset',
    'Others'
  ];

  StreamSubscription<EmvCard?>? _subscription;

  final page_controller = PageController();

  // ====== LIFECYCLE METHODS ======
  @override
  void initState() {
    super.initState();
    loadAssets();
    checkNFC();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HIGHTLIGHT_COLOR,
      appBar: BugAppBar('Your Assets'),
      body: assets.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(ResStyle.spacing),
              child: Column(
                children: [
                  BugPageIndicator(page_controller, 2),
                  Expanded(
                    child: PageView(
                      controller: page_controller,
                      children: [
                        _buildAssetList(),
                        _buildTutorialPage(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _buildTutorialPage(),
    );
  }

  // ====== CORE FUNCTIONS ======
  Future<void> loadAssets() async {
    assets = await Asset.getAssetList();
    setState(() {});
  }

  void _selectOption(String option) {
    showAddAssetDialog(option);
  }

  void navigateToTransactionPage(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
          asset: asset,
          type: "Asset",
        ),
      ),
    ).then((_) => loadAssets());
  }

  void _goToNextPage() async {
    // await page_controller.nextPage(
    //     duration: Duration(milliseconds: 600), curve: Curves.fastOutSlowIn);

    page_controller.nextPage(
      duration: Duration(milliseconds: 700),
      curve: Curves.fastOutSlowIn,
    );
  }

  // ====== NFC RELATED FUNCTIONS ======
  Future<void> startReading() async {
    setState(() {
      NFC_reading = true;
    });

    bool started = await card_reader.start();
    if (started) {
      _subscription = card_reader.stream().listen((EmvCard? card) async {
        if (card != null && card.number != null) {
          var code = "${card.number?.substring(12)}-${(card.expire ?? '')}}";
          var asset = await Asset.getBankCardByUniqueCode(code);

          if (asset != null) {
            showActionSheet(asset);
          } else {
            showAddAssetDialog(assetTypes[1], card: card);
            stopReading();
          }
        }
      }, onError: (error) {
        setState(() {
          NFC_reading = false;
        });
      });
    }
  }

  Future<void> stopReading() async {
    await card_reader.stop();
    _subscription?.cancel();
    setState(() {
      NFC_reading = false;
    });
  }

  Future<void> checkNFC() async {
    bool NFC_status = await EmvCardReader.available();

    if (!NFC_status) {
      bool? userConfirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('NFC Disabled'),
            content: const Text(
                'NFC is currently disabled. Would you like to open the NFC settings?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (userConfirmed ?? false) {
        NFC_status = await EmvCardReader.openNFCSetting(context);
      }
    }

    if (NFC_status) {
      startReading();
    }
    setState(() {});
  }

  // ====== DIALOG WIDGETS ======
  void showActionSheet(Asset asset) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(asset.name),
        message: Text('RM${asset.value.toStringAsFixed(2)}'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showEditAssetDetailsDialog(asset);
            },
            child: const Text('Edit Asset Details'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              navigateToTransactionPage(asset);
            },
            child: const Text('Make Transaction'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showDeleteConfirmationDialog(asset);
            },
            child:
                const Text('Delete Asset', style: TextStyle(color: Colors.red)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${asset.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Asset.deleteAsset(asset.id!, false);
                await loadAssets();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void showEditAssetDetailsDialog(Asset asset) {
    final TextEditingController nameController =
        TextEditingController(text: asset.name);
    final TextEditingController descController =
        TextEditingController(text: asset.desc);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Asset Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Asset Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                asset.name = nameController.text;
                asset.desc = descController.text;
                await Asset.updateAsset(asset);
                await loadAssets();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showAddAssetDialog(String selectedType, {EmvCard? card}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String? unique_code;

    if (card != null) {
      nameController.text = 'Card ' + (card.number?.substring(12) ?? '');
      descController.text =
          (card.type ?? '') + " expired at " + (card.expire ?? '');

      unique_code = "${card.number?.substring(12)}-${(card.expire ?? '')}}";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Asset'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Asset Name'),
                ),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: assetTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Asset Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                startReading();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Asset newAsset = Asset(
                  'user_code',
                  name: nameController.text,
                  value: double.tryParse(valueController.text) ?? 0.0,
                  desc: descController.text,
                  type: selectedType,
                  unique_code: unique_code,
                  status: true,
                );

                await Asset.insertAsset(newAsset);
                await loadAssets();
                startReading();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ====== UI WIDGETS ======

  Widget _buildIcon(String assetType) {
    IconData icon;
    switch (assetType) {
      case 'Cash':
        icon = Icons.attach_money;
        break;
      case 'Bank Card':
        icon = Icons.credit_card;
        break;
      case 'Property':
        icon = Icons.home;
        break;
      case 'Stock':
        icon = Icons.show_chart;
        break;
      case 'Digital Asset':
        icon = Icons.cloud;
        break;
      default:
        icon = Icons.category;
    }
    return Icon(icon, size: ResStyle.spacing * 4, color: RM1_COLOR);
  }

  Widget _buildAssetCard(BuildContext context, String assetType) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 3,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(assetType),
          SizedBox(height: 8),
          Text(
            assetType,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (assetType == 'Bank Card')
            Center(
              child: Text(
                'Quick Add your card using NFC ',
                style: TextStyle(),
                textAlign: TextAlign.center,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildAssetList() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: assets.map((asset) {
              return AssetDetailCard(asset, () => showActionSheet(asset));
            }).toList(),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: BugPrimaryButton(
              text: 'Add More Asset >>',
              onPressed: _goToNextPage,
              color: TITLE_COLOR),
        ),
      ],
    );
  }

  // Widget _buildAssetTypeList() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     physics: const BouncingScrollPhysics(),
  //     child: Row(
  //       children: List.generate(assetTypes.length, (index) {
  //         return GestureDetector(
  //           onTap: () => _selectOption(assetTypes[index]),
  //           child: Container(
  //             margin: EdgeInsets.all(ResStyle.spacing),
  //             padding: EdgeInsets.symmetric(
  //               vertical: ResStyle.spacing,
  //               horizontal: ResStyle.spacing,
  //             ),
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: RM20_COLOR,
  //               borderRadius: BorderRadius.circular(8),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.withOpacity(0.3),
  //                   spreadRadius: 1,
  //                   blurRadius: 3,
  //                   offset: Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.add, color: TITLE_COLOR),
  //                 SizedBox(width: ResStyle.spacing / 2),
  //                 Text(
  //                   assetTypes[index],
  //                   style: TextStyle(
  //                     fontSize: ResStyle.font,
  //                     color: TITLE_COLOR,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       }),
  //     ),
  //   );
  // }

  Widget _buildTutorialPage() {
    return Padding(
      padding: EdgeInsets.all(ResStyle.spacing),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: assetTypes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => showAddAssetDialog(assetTypes[index]),
                  child: _buildAssetCard(context, assetTypes[index]),
                );
              },
            ),
          ),
          BugInfoCard(
              'Your financial data will never be shared with third parties. Any processing of your sensitive financial data in the server, with your permission, will be securely encrypted. Thank you for your trust.')
        ],
      ),
    );
  }
}
