import 'dart:async';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/bank_card_nfc/bank_card_nfc_bloc.dart';
import 'package:build_growth_mobile/models/card.dart';
import 'package:build_growth_mobile/services/emv_card_reader.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/financial/TransactionPage2.dart';
import 'package:build_growth_mobile/pages/financial/transaction_page.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_emoji.dart';
import 'package:build_growth_mobile/widget/bug_input.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AssetDetailPage extends StatefulWidget {
  const AssetDetailPage({super.key});

static   final page_controller = PageController();
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
    'Deposit Account',
    'Other Asset'
  ];

  final GlobalKey<State> dialog_key = GlobalKey<State>();
  bool isLoading = true;

  StreamSubscription<EmvCard?>? _subscription;



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
 //   page_controller.dispose();
 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HIGHTLIGHT_COLOR,
        appBar: BugAppBar('Your Assets', context),
        body: BlocListener<BankCardNfcBloc, BankCardNfcState>(
          listener: (context, state) async {
            if (state is BankCardDetectedState) {
              var card = state.card;
              var code =
                  "${card.number?.substring(12)}-${(card.expire ?? '')}}";
              var asset = await Asset.getBankCardByUniqueCode(code);

              if (asset != null) {
                showActionSheet(asset);
              } else {
                showAddAssetModal(assetTypes[1], card: card);
                stopReading();
              }
            } else if (state is BankCardInitialState) {
              startReading();
            }
          },
          child: (isLoading)
              ? BugLoading()
              : assets.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(ResStyle.spacing),
                      child: Column(
                        children: [
                          BugPageIndicator(AssetDetailPage.page_controller, 2),
                          Expanded(
                            child: PageView(
                              controller: AssetDetailPage.page_controller,
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
        ));
  }

  // ====== CORE FUNCTIONS ======
  Future<void> loadAssets() async {
    assets = await Asset.getAssetList();
    isLoading = false;
    setState(() {});
  }

  void _selectOption(String option) {
    showAddAssetModal(option);
  }

  void navigateToTransactionPage(Asset asset, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) => loadAssets());
  }

  void _goToNextPage() async {
    // await page_controller.nextPage(
    //     duration: Duration(milliseconds: 600), curve: Curves.fastOutSlowIn);

    AssetDetailPage.page_controller.nextPage(
      duration: Duration(milliseconds: 700),
      curve: Curves.fastOutSlowIn,
    );
  }

  // ====== NFC RELATED FUNCTIONS ======
  Future<void> startReading() async {
    if (NFC_reading) {
      return;
    }
    setState(() {
      NFC_reading = true;
    });

    bool started = await card_reader.start();
    if (started) {
      _subscription = card_reader.stream().listen((EmvCard? card) async {
        if (card != null && card.number != null) {
          BlocProvider.of<BankCardNfcBloc>(context)
              .add(BankCardDetectedEvent(card: card));
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
        title: Text(
          asset.name,
          style: TextStyle(color: TITLE_COLOR), // Title color
        ),
        message: Text(
          'RM${asset.value.toStringAsFixed(2)}',
          style: TextStyle(
              color: TITLE_COLOR, fontSize: ResStyle.font), // Title color
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showEditAssetDetailsDialog(asset);
            },
            child: Text(
              'Edit Asset Details',
              style: TextStyle(
                  color: TITLE_COLOR,
                  fontSize: ResStyle.font), // Title color for regular actions
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              navigateToTransactionPage(
                asset,
                TransactionPage2(
                  asset: asset,
                  intention: "Asset Transaction",
                ),
              );
            },
            child: Text(
              'Make Transaction',
              style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              navigateToTransactionPage(
                asset,
                TransactionPage2(
                  asset: asset,
                  intention: "Asset Transfer",
                ),
              );
            },
            child: Text(
              'Transfer Asset',
              style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showDeleteConfirmationDialog(asset);
            },
            child: Text(
              'Delete Asset',
              style: TextStyle(
                  color: DANGER_COLOR,
                  fontSize: ResStyle.font), // Danger color for delete action
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
                color: DANGER_COLOR,
                fontSize: ResStyle.font), // Title color for cancel button
          ),
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BugInfoDialog(
          title: 'Delete Confirmation',
          main_color: DANGER_COLOR, // Set a color for the delete confirmation
          message: 'Are you sure you want to delete "${asset.name}"?',
          actions: [
            BugPrimaryButton(
                onPressed: () async {
                  // Perform delete action here

                  await Asset.deleteAsset(asset.id!, false);
                  await loadAssets();
                  Navigator.of(context).pop(); // Close the dialog after delete
                },
                text: 'Delete',
                color: DANGER_COLOR),
            SizedBox(
              height: ResStyle.spacing,
            ),
            BugPrimaryButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                text: 'Cancel',
                color: PRIMARY_COLOR),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BugBottomModal(
            context: context,
            header: 'Edit ${asset.type}\n${asset.name}',
            widgets: [
              BugTextInput(
                controller: nameController,
                label: 'Asset Name',
                hint: 'Enter Asset Name',
                prefixIcon: Icon(getIcon(asset.type)),
              ),
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                controller: descController,
                label: 'Description',
                hint: 'Enter Description',
                prefixIcon: Icon(Icons.note_alt_sharp),
                validator: (p0) {
                  return null;
                },
              ),
              SizedBox(height: ResStyle.spacing * 2),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BugPrimaryButton(
                      color: RM50_COLOR,
                      onPressed: () async {
                        asset.name = nameController.text;
                        asset.desc = descController.text;
                        await Asset.updateAsset(asset);
                        await loadAssets();
                        Navigator.of(context).pop();
                      },
                      text: 'Update',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BugPrimaryButton(
                      onPressed: () {
                        startReading();
                        Navigator.of(context).pop();
                      },
                      color: DANGER_COLOR,
                      text: 'Cancel',
                    ),
                  ),
                )
              ])
            ]);
      },
    );
  }

  void showAddAssetModal(String selectedType, {EmvCard? card}) async {
    final TextEditingController nameController =
        TextEditingController(text: 'New ${selectedType}');
    final TextEditingController valueController =
        TextEditingController(text: 'RM 0.00');
    final TextEditingController descController = TextEditingController();
    String? unique_code;

    if (dialog_key.currentContext!= null) {
       Navigator.pop(context); // Close the dialog
       await Future.delayed(const Duration(milliseconds: 300));
    }
    
    if (card != null) {
      nameController.text = 'Card ' + (card.number?.substring(12) ?? '');
      descController.text =
          (card.type ?? '') + " expired at " + (card.expire ?? '');
      unique_code = "${card.number?.substring(12)}-${(card.expire ?? '')}}";
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BugBottomModal(
            context: context,
            key: dialog_key,
            header: 'Add New ${selectedType}',
            widgets: [
              BugTextInput(
                controller: nameController,
                label: 'Asset Name',
                hint: 'Enter Asset Name',
                prefixIcon: Icon(getIcon(selectedType)),
              ),
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                controller: valueController,
                label: 'Amount (RM)',
                hint: 'Enter Amount (RM)',
                prefixIcon: Icon(Icons.diamond_sharp),
                onChanged: (value) {
                  FormatterHelper.implement_RM_format(valueController, value);
                },
              ),
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                controller: descController,
                label: 'Description',
                hint: 'Enter Description',
                prefixIcon: Icon(Icons.note_alt_sharp),
                validator: (p0) {
                  return null;
                },
              ),
              SizedBox(height: ResStyle.spacing),
              SizedBox(height: ResStyle.spacing * 2),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BugPrimaryButton(
                      onPressed: () {
                        startReading();
                        Navigator.of(context).pop();
                      },
                      color: DANGER_COLOR,
                      text: 'Cancel',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BugPrimaryButton(
                      color: RM50_COLOR,
                      onPressed: () async {
                        Asset newAsset = Asset(
                          UserToken.user_code,
                          name: nameController.text,
                          value: FormatterHelper.getAmountFromRM(
                              valueController.text),
                          desc: descController.text,
                          type: selectedType,
                          unique_code: unique_code,
                          status: true,
                        );

                        await Asset.insertAsset(newAsset);
                        await loadAssets();
                       
                        Navigator.of(context).pop();

                        if (AssetDetailPage.page_controller.hasClients) {
                          AssetDetailPage.page_controller.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.fastOutSlowIn,
                          );
                        }
                      },
                      text: 'Add',
                    ),
                  ),
                ),
              ])
            ]);
      },
    );

    BlocProvider.of<BankCardNfcBloc>(context).add(BankCardDisappearEvent());
  }

  // ====== UI WIDGETS ======

  Widget _buildIcon(String assetType) {
    IconData icon = getIcon(assetType);
    return Icon(icon, size: ResStyle.spacing * 4, color: RM1_COLOR);
  }

  IconData getIcon(String assetType) {
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
      case 'Deposit Account':
        icon = Icons.savings;
        break;
      default:
        icon = Icons.category;
    }

    return icon;
  }

  Widget _buildAssetCard(BuildContext context, String assetType, GlobalKey key) {
    return Container(
      key: key,
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
          SizedBox(height: ResStyle.spacing / 2),
          Text(
            assetType,
            style: TextStyle(
              fontSize: ResStyle.medium_font,
              fontWeight: FontWeight.w600,
              color: TEXT_COLOR,
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
                  onTap: () => showAddAssetModal(assetTypes[index]),
                  child: _buildAssetCard(context, assetTypes[index], TutorialHelper.assetKeys[index]),
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
