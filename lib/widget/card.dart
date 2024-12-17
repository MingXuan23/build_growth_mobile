import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_input.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Widget AssetCard(String header, String text, Function() func,
    {Color color = RM1_COLOR, Color font_color = TEXT_COLOR // Default color
    }) {
  return GestureDetector(
    onTap: () => func(),
    child: Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResStyle.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: HIGHTLIGHT_COLOR),
                SizedBox(width: 0.5 * ResStyle.spacing),
                Text(
                  header,
                  style: TextStyle(
                    color: HIGHTLIGHT_COLOR,
                    fontSize: ResStyle.font,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResStyle.spacing),
            Text(
              text,
              style: TextStyle(
                  fontSize: ResStyle.header_font,
                  fontWeight: FontWeight.bold,
                  color: font_color),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget GeneralCard(String text, Function() func, {String title = ''}) {
  return GestureDetector(
    onTap: () => func,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget AssetDetailCard(Asset asset, VoidCallback func,
    {Color color = RM1_COLOR}) {
  return GestureDetector(
    onTap: () => func(),
    child: Container(
      margin: EdgeInsets.symmetric(vertical: ResStyle.spacing),
      padding: EdgeInsets.all(ResStyle.spacing),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PRIMARY_COLOR,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asset.name,
            style: TextStyle(
                fontSize: ResStyle.body_font,
                fontWeight: FontWeight.bold,
                color: TEXT_COLOR),
          ),
          if (asset.desc.isNotEmpty) ...[
            SizedBox(height: 0.5 * ResStyle.spacing),
            Text(
              asset.desc,
              style: TextStyle(
                fontSize: ResStyle.medium_font,
                color: TEXT_COLOR,
              ),
            ),
          ],
          SizedBox(height: 0.5 * ResStyle.spacing),
          Text(
            'RM ${asset.value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ResStyle.body_font,
              color: TEXT_COLOR,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget DebtDetailCard(Debt debt, VoidCallback func,
    {Color color = TITLE_COLOR}) {
  var paid = FormatterHelper.isSameMonthYear(debt.last_payment_date);
  return GestureDetector(
    onTap: () => func(),
    child: Container(
      margin: EdgeInsets.symmetric(vertical: ResStyle.spacing),
      padding: EdgeInsets.all(ResStyle.spacing),
      decoration: BoxDecoration(
        color: paid
            ? RM5_COLOR
            : TITLE_COLOR, // Using the same color scheme as AssetDetailPage
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: TextStyle(
                    fontSize: ResStyle.body_font,
                    fontWeight: FontWeight.bold,
                    color:
                        HIGHTLIGHT_COLOR, // Using primary color for consistency
                  ),
                ),
                if (debt.desc!.isNotEmpty) ...[
                  SizedBox(height: 0.5 * ResStyle.spacing),
                  Text(
                    debt.desc!,
                    style: TextStyle(
                      fontSize: ResStyle.medium_font,
                      color: HIGHTLIGHT_COLOR, // Using secondary color
                    ),
                  ),
                ],
                SizedBox(height: 0.5 * ResStyle.spacing),
                Text(
                  'RM ${debt.monthly_payment.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: ResStyle.body_font,
                    color: HIGHTLIGHT_COLOR, // Using primary color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (paid) ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: HIGHTLIGHT_COLOR,
                  size: 3 * ResStyle.spacing,
                ), // Using primary color
                SizedBox(height: 0.5 * ResStyle.spacing),
                Text(
                  FormatterHelper.dateFormat(debt.last_payment_date!),
                  style: TextStyle(
                    fontSize: ResStyle.body_font,
                    color: HIGHTLIGHT_COLOR, // Using primary color
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

String getMonthName(int month) {
  const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return monthNames[month - 1]; // Subtract 1 since the list is 0-based
}

Widget ExpenseDetailCard(Debt debt, VoidCallback func,
    {Color color = TITLE_COLOR}) {
  // var paid = FormatterHelper.isSameMonthYear(debt.last_payment_date);

  return GestureDetector(
    onTap: () => func(),
    child: Container(
      margin: EdgeInsets.symmetric(vertical: ResStyle.spacing),
      padding: EdgeInsets.all(ResStyle.spacing),
      decoration: BoxDecoration(
        color: TITLE_COLOR, // Using the same color scheme as AssetDetailPage
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: TextStyle(
                    fontSize: ResStyle.body_font,
                    fontWeight: FontWeight.bold,
                    color:
                        HIGHTLIGHT_COLOR, // Using primary color for consistency
                  ),
                ),
                if (debt.desc!.isNotEmpty) ...[
                  SizedBox(height: 0.5 * ResStyle.spacing),
                  Text(
                    debt.desc!,
                    style: TextStyle(
                      fontSize: ResStyle.medium_font,
                      color: HIGHTLIGHT_COLOR, // Using secondary color
                    ),
                  ),
                ],
                SizedBox(height: 0.5 * ResStyle.spacing),
                Row(
                  children: [
                    Text(
                      "${FormatterHelper.toDoubleString(debt.month_total_expense)}",
                      style: TextStyle(
                        fontSize: ResStyle.body_font,
                        color: HIGHTLIGHT_COLOR, // Using primary color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: ResStyle.spacing,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: HIGHTLIGHT_COLOR,
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ResStyle.spacing / 2),
                        child: Text(
                            '${getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                            style: TextStyle(
                              fontSize: ResStyle.font,
                              color: TITLE_COLOR, // Using primary color
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    )
                  ],
                ),
                Text(
                  'Total Spending: ${FormatterHelper.toDoubleString(debt.total_expense)}',
                  style: TextStyle(
                    fontSize: ResStyle.small_font,
                    color: HIGHTLIGHT_COLOR, // Using primary color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget BugInfoCard(String message) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: EdgeInsets.only(bottom: ResStyle.spacing),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ResStyle.spacing, vertical: ResStyle.spacing),
        decoration: BoxDecoration(
          color: TITLE_COLOR,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, color: HIGHTLIGHT_COLOR),
            SizedBox(width: ResStyle.spacing),
            Flexible(
              child: Text(
                message,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: ResStyle.small_font,
                  fontWeight: FontWeight.bold,
                  color: HIGHTLIGHT_COLOR,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget BugHeaderCard(String message) {
  return Padding(
    padding: EdgeInsets.only(bottom: ResStyle.spacing),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResStyle.spacing,
              vertical: ResStyle.spacing,
            ),
            decoration: BoxDecoration(
              color: TITLE_COLOR,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              softWrap: true,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResStyle.medium_font,
                fontWeight: FontWeight.bold,
                color: HIGHTLIGHT_COLOR,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget CardInfoDivider(String title, String info, {bool isLast = false}) {
  return Wrap(
    children: [
      ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: ResStyle.font),
        ),
        subtitle: Text(
          info,
          style: TextStyle(fontSize: ResStyle.medium_font),
        ),
      ),
      if (!isLast) const Divider(),
    ],
  );
}

Widget CardWidgetivider(String title, Widget trailing, {bool isLast = false}) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ResStyle.spacing, vertical: ResStyle.spacing / 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResStyle.medium_font,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: ResStyle.spacing),
                trailing,
                // Expanded(
                //   //flex: 2,
                //   child: SizedBox(
                //     //height: 10, // Fixed height for progress indicator
                //     child: trailing,
                //   ),
                // )
              ],
            );
          },
        ),
      ),
      if (!isLast) const Divider(),
    ],
  );
}

class TransactionCard extends StatefulWidget {
  final Transaction transaction;
  final Function loadData;
  const TransactionCard(
      {Key? key, required this.transaction, required this.loadData})
      : super(key: key);

  @override
  _TransactionCardState createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  String proofPath = '';
  bool proofExists = false;

  @override
  void initState() {
    super.initState();
    checkProof(widget.transaction);
  }

  // Function to check if proof image exists
  Future<void> checkProof(Transaction t) async {
    final dir = await getApplicationDocumentsDirectory();

    if (t.image != null) {
      if (await File(t.image ?? "").exists()) {
        setState(() {
          proofPath = t.image ?? "";
          proofExists = true;
        });

        return;
      }
    }

    String now = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '');

    //for checking missing photo
    final jpgPath = path.join(dir.path, '${now}_${widget.transaction.id}.jpg');
    final pngPath = path.join(dir.path, '${now}_${widget.transaction.id}.png');

    if (await File(jpgPath).exists()) {
      setState(() {
        proofPath = jpgPath;
        proofExists = true;
      });
    } else if (await File(pngPath).exists()) {
      setState(() {
        proofPath = pngPath;
        proofExists = true;
      });
    } else {
      setState(() {
        proofExists = false;
      });
    }
  }

  // Function to pick an image from a given source
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final dir = await getApplicationDocumentsDirectory();
      final extension = path.extension(image.path);
      final newPath = path.join(dir.path,
          'transaction_${widget.transaction.id}_${UserToken.user_code}$extension');

      await File(image.path).copy(newPath);

      Transaction t = widget.transaction;
      t.image = newPath;
      Transaction.updateTransaction(t);
      setState(() {
        proofPath = newPath;
        proofExists = true;
      });

      if (UserToken.online && UserPrivacy.googleDriveBackup) {
        try {
          await GoogleDriveBackupHelper.uploadTransactionImage(t);
        } catch (e) {}
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(BugSnackBar('Add Transaction Proof Successfully!', 3));
    }
  }

  // Function to add proof using a Cupertino Action Sheet
  Future<void> addProof() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await _pickImage(ImageSource.camera);
            },
            child: Text('Take Photo',
                style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await _pickImage(ImageSource.gallery);
            },
            child: Text('Choose from Gallery',
                style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel',
              style: TextStyle(color: DANGER_COLOR, fontSize: ResStyle.font)),
        ),
      ),
    );
  }

  // Function to delete the proof image
  Future<void> deleteProof() async {
    final file = File(proofPath);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        proofPath = '';
        proofExists = false;
      });

      Transaction t = widget.transaction;
      t.image = null;
      Transaction.updateTransaction(t);
      Navigator.pop(context);
    }
  }

  // Placeholder for saving to gallery
  void saveToGallery() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Image saved to gallery')));
  }

  // Function to view the proof image
  void viewProof() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return BugBottomModal(
              additionHeight: ResStyle.height * 0.15,
              context: context,
              header: 'Transaction Proof',
              widgets: [
                Image.file(
                  File(proofPath),
                  height: ResStyle.height * 0.5,
                ),
                SizedBox(height: ResStyle.spacing),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BugIconButton(
                          text: 'Save To Gallery',
                          icon: Icons.save,
                          onPressed: saveToGallery,
                          color: SUCCESS_COLOR,
                          text_color: HIGHTLIGHT_COLOR),
                      BugIconButton(
                          text: 'Delete',
                          icon: Icons.delete,
                          onPressed: deleteProof,
                          color: DANGER_COLOR,
                          text_color: HIGHTLIGHT_COLOR),
                    ])
              ]);
        });
  }

// Function to show the modal sheet for editing the note
  void _showEditNoteModal() {
    TextEditingController _noteController =
        TextEditingController(text: widget.transaction.desc);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // To allow the modal sheet to expand fully
      builder: (context) {
        return BugBottomModal(
            context: context,
            additionHeight: -ResStyle.height * 0.2,
            header: 'Transaction',
            widgets: [
              BugTextInput(
                controller: _noteController,
                label: 'Transaction Note',
                hint: 'Enter your note',
                prefixIcon: Icon(Icons.note_alt),
              ),
              SizedBox(
                height: ResStyle.spacing * 5,
              ),
              BugPrimaryButton(
                  text: 'Save Note',
                  color: TITLE_COLOR,
                  onPressed: () {
                    _saveNote(_noteController.text);
                    Navigator.of(context).pop();
                  }),
              SizedBox(
                height: ResStyle.spacing,
              ),
              BugPrimaryButton(
                  text: 'Delete This Transaction',
                  color: DANGER_COLOR,
                  onPressed: () {
                    _deleteNote();
                  }),
            ]);
      },
    );
  }

// Function to save the updated note
  void _saveNote(String newNote) {
    setState(() {
      widget.transaction.desc = newNote;
    });
    Transaction.updateTransaction(widget.transaction);
    ScaffoldMessenger.of(context)
        .showSnackBar(BugSnackBar('Update Transaction Successfully', 5)
            //SnackBar(content: Text('Note updated successfully!')),
            );
    Navigator.of(context).pop();
    widget.loadData();
  }

// Function to delete the note
  void _deleteNote() {
    Transaction.deleteTransaction(widget.transaction.id ?? -1);
    ScaffoldMessenger.of(context)
        .showSnackBar(BugSnackBar('Delete Transaction Successfully', 5)
            //SnackBar(content: Text('Note deleted successfully!')),
            );
    widget.loadData();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEditNoteModal, // ,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: Colors.black,
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.transaction.asset != null)
                    Text('From: ${widget.transaction.asset!.name}',
                        style: TextStyle(color: Colors.green)),
                  if (widget.transaction.debt != null)
                    Text('For: ${widget.transaction.debt!.name}',
                        style: TextStyle(color: Colors.green)),
                  Text('Note: ${widget.transaction.desc}',
                      style: TextStyle(color: Colors.black87)),
                  Text(
                      'Date: ${widget.transaction.created_at.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    FormatterHelper.toDoubleString(widget.transaction.amount),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: TITLE_COLOR),
                  ),
                  BugSmallButton(
                    text: proofExists ? 'View Proof' : 'Add Proof',
                    onPressed: proofExists ? viewProof : addProof,
                    color: proofExists ? SUCCESS_COLOR : TITLE_COLOR,
                    borderRadius: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
