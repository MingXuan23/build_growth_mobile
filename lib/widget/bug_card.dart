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

import 'dart:math';
import 'package:flutter/material.dart';

import 'dart:math'; // Required for log function

Widget FoodCourtCard({
  required String name,
  required String value, // Value to calculate stars from using log10
  Color cardColor = const Color(0xFFFF7B9C), // Pink color from image
  VoidCallback? onTap,
}) {
  // Calculate stars based on log10 value, clamped between 0 and 5
  double calculateStars(String string_value) {
    double value;
    try {
      value = double.parse(string_value);
    } catch (e) {
      // If parsing fails, return 1 star (or handle as needed)
      return 1.0;
    }

    if (value <= 0) return 1.0; // Ensure minimum star value
    double stars = log(value) / ln10; // log10 calculation
    return stars.clamp(1.0, 5.0); // Clamp between 1 and 5 stars
  }

  final double stars = calculateStars(value);
  final int fullStars = stars.floor();
  final double remainingStars = stars - fullStars;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 8,
        shadowColor: cardColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.9),
                cardColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
              horizontal: ResStyle.spacing, vertical: ResStyle.spacing / 2),
          child: Row(
            children: [
              // Left side - Icon and details
              Container(
                padding: EdgeInsets.all(ResStyle.spacing / 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResStyle.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResStyle.header_font,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResStyle.spacing / 2),
                    Text(
                      "Location details", // Optional text, adjust as needed
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: ResStyle.body_font,
                      ),
                    ),
                  ],
                ),
              ),
              // Right side - Rating
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stars.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    // Display full and partial star icons
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 16,
                    ),
                    Icon(
                      Icons.star,
                      color: (remainingStars > 0) ? Colors.yellow : Colors.grey,
                      size: 16,
                    ),
                    Icon(
                      Icons.star,
                      color: (remainingStars > 1) ? Colors.yellow : Colors.grey,
                      size: 16,
                    ),
                    Icon(
                      Icons.star,
                      color: (remainingStars > 2) ? Colors.yellow : Colors.grey,
                      size: 16,
                    ),
                    Icon(
                      Icons.star,
                      color: (remainingStars > 3) ? Colors.yellow : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget BubbleEffect(double size,
    {double? top,
    double? bottom,
    double? left,
    double? right,
    Color color = RM1_COLOR,
    double? width}) {
  return Positioned(
    top: top,
    left: left,
    bottom: bottom,
    right: right,
    child: Container(
      width: width ?? size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            RM1_COLOR.withOpacity(0.4),
            RM1_COLOR.withOpacity(0.2),
          ],
        ),
      ),
    ),
  );
}
// Widget AssetCard(
//   String header,
//   String text,
//   Function() func, {
//     GlobalKey? gkey ,
//   Color color = RM1_COLOR,
//   Color fontColor = TEXT_COLOR, // Default text color
// }) {
//   return GestureDetector(
//     key: gkey,
//     onTap: () => func(),
//     child: Card(

//       elevation: 6,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Container(

//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               color.withOpacity(0.9),
//               color.withOpacity(0.7),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: TITLE_COLOR.withOpacity(0.1),
//               blurRadius: 10,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: EdgeInsets.symmetric(horizontal:  ResStyle.spacing, vertical: ResStyle.spacing/2),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding:  EdgeInsets.all(ResStyle.spacing/2),
//                   decoration: BoxDecoration(
//                     color: HIGHTLIGHT_COLOR.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.account_balance_wallet,
//                     color: HIGHTLIGHT_COLOR,
//                   ),
//                 ),
//                 SizedBox(width: ResStyle.spacing),
//                 Expanded(
//                   child: Text(
//                     header,
//                     style: TextStyle(
//                       color: HIGHTLIGHT_COLOR,
//                       fontSize: ResStyle.header_font,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 1.2,
//                     ),
//                     overflow: TextOverflow.visible,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: ResStyle.spacing/2),
//             Text(
//               text,
//               maxLines: 2,
//               overflow: TextOverflow.visible,
//               style: TextStyle(
//                 fontSize: text.length >= 15
//                     ? ResStyle.body_font
//                     : ResStyle.header_font,
//                 fontWeight: FontWeight.bold,
//                 color: fontColor,
//               //  height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

Widget AssetCard(
  String header,
  String text,
  Function() func, {
  GlobalKey? gkey,
  Color color = RM1_COLOR,
  Color fontColor = TEXT_COLOR, // Default text color
}) {
  return GestureDetector(
    key: gkey,
    onTap: () => func(),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              HIGHTLIGHT_COLOR.withOpacity(0.7)
              // color.withOpacity(0.7),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: RM20_COLOR.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
            horizontal: ResStyle.spacing, vertical: ResStyle.spacing / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: ResStyle.spacing * 2.5,
                  width: ResStyle.spacing * 2.5,
                  padding: EdgeInsets.all(ResStyle.spacing / 2),
                  decoration: BoxDecoration(
                    color: LOGO_COLOR.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monetization_on,
                    color: HIGHTLIGHT_COLOR,
                    size: ResStyle.spacing *1.5,
                  ),
                ),
                SizedBox(width: ResStyle.spacing),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: text.length >= 15
                          ? ResStyle.font
                          : ResStyle.body_font,
                      fontWeight: FontWeight.w900,
                      color: fontColor,
                      //  height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget TutorialCard(String text) {
  return Padding(
    padding: EdgeInsets.all(ResStyle.spacing),
    child: Container(
        padding:
            EdgeInsets.all(ResStyle.spacing), // Adds padding around the text
        decoration: BoxDecoration(
          color: RM50_COLOR, // Black background color
          // border: Border.all(color: RM1_COLOR, width: ResStyle.small_font /2), // Yellow border
          borderRadius: BorderRadius.circular(8), // Optional rounded corners
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: HIGHTLIGHT_COLOR, // Text color for better contrast
            fontSize: ResStyle.font, // Use your defined font size
            fontWeight: FontWeight.bold, // Bold text
          ),
        )),
  );
}

Widget DebtCard(
  String header,
  String text,
  Function() func, {
  Color color = RM1_COLOR,
  Color font_color = TEXT_COLOR,
  String? infotext,
  GlobalKey? gkey,
  IconData? icon
}) {
  return GestureDetector(
    key: gkey,
    onTap: () => func(),
    child: Container(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(ResStyle.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResStyle.spacing / 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon??Icons.account_balance_wallet,
                        color: HIGHTLIGHT_COLOR,
                        size: ResStyle.spacing,
                      ),
                    ),
                    SizedBox(width: ResStyle.spacing),
                    Expanded(
                      child: Text(
                        header,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResStyle.font,
                          fontWeight: FontWeight.w600,
                          color: HIGHTLIGHT_COLOR,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResStyle.spacing / 2),
                // Main Text

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: text.length >= 15
                            ? ResStyle.font
                            : ResStyle.body_font,
                        fontWeight: FontWeight.bold,
                        color: font_color,
                      ),
                    ),
                    if (infotext != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResStyle.spacing,
                          vertical: ResStyle.spacing / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin:
                                  EdgeInsets.only(right: ResStyle.spacing / 2),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              infotext,
                              maxLines: 2,
                              style: TextStyle(
                                color: color,
                                fontSize: ResStyle.medium_font,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget GeneralCard({
  required double totalInflow,
  required double totalOutflow,
  required int selectedMonth,
  required int selectedYear,
  required Function(int month, int year) onMonthYearChanged,
}) {
  final currentDate = DateTime.now();
  final startYear = 2020;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: HIGHTLIGHT_COLOR,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: TITLE_COLOR.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month and Year Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Month Dropdown
            SizedBox(
              width: ResStyle.spacing * 2,
            ),
            Expanded(
              child: DropdownButton<int>(
                value: selectedMonth,
                dropdownColor: HIGHTLIGHT_COLOR,
                isExpanded: true,
                items: List.generate(12, (index) {
                  final month = index + 1;
                  final isDisabled = selectedYear == currentDate.year &&
                      month > currentDate.month;

                  return DropdownMenuItem(
                    alignment: Alignment.center,
                    value: month,
                    enabled: !isDisabled,
                    child: Text(
                      textAlign: TextAlign.center,
                      FormatterHelper.getMonthName(month),
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : Colors.black,
                      ),
                    ),
                  );
                }),
                onChanged: (month) {
                  if (month != null) {
                    onMonthYearChanged(month, selectedYear);
                  }
                },
              ),
            ),

            // Year Selection with arrows
            SizedBox(
              width: ResStyle.spacing,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: selectedYear <= startYear
                      ? null
                      : () =>
                          onMonthYearChanged(selectedMonth, selectedYear - 1),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    selectedYear.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: selectedYear >= currentDate.year
                      ? null
                      : () =>
                          onMonthYearChanged(selectedMonth, selectedYear + 1),
                ),
                SizedBox(
                  width: ResStyle.spacing,
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: ResStyle.spacing,
        ),

        // Inflow and Outflow Totals
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Inflow:',
              style: TextStyle(
                  fontSize: ResStyle.medium_font, fontWeight: FontWeight.bold),
            ),
            Text(
              'RM ${totalInflow.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: ResStyle.medium_font, color: Colors.green),
            ),
          ],
        ),
        SizedBox(
          height: ResStyle.spacing / 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Outflow:',
              style: TextStyle(
                  fontSize: ResStyle.medium_font, fontWeight: FontWeight.bold),
            ),
            Text(
              'RM ${totalOutflow.toStringAsFixed(2)}',
              style:
                  TextStyle(fontSize: ResStyle.medium_font, color: Colors.red),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget AssetDetailCard(Asset asset, VoidCallback func,
    {Color color = RM1_COLOR, required IconData icon}) {
  return GestureDetector(
    onTap: () => func(),
    child: Container(
      margin: EdgeInsets.symmetric(
          vertical: ResStyle.spacing, horizontal: ResStyle.spacing / 4),
      padding: EdgeInsets.all(ResStyle.spacing),
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [
          color,
          HIGHTLIGHT_COLOR
          // color.withOpacity(0.7),
        ], radius: ResStyle.spacing 
            // begin: Alignment.topCenter,
            // end: Alignment.centerRight,
            ),
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: LOGO_COLOR,
        //     blurRadius: 3,
        //     offset: const Offset(1, 2),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyle(
                      fontSize: ResStyle.body_font,
                      fontWeight: FontWeight.bold,
                      color: LOGO_COLOR),
                ),
                if (asset.desc.isNotEmpty) ...[
                  SizedBox(height: 0.25 * ResStyle.spacing),
                  Text(
                    asset.desc,
                    style: TextStyle(
                      fontSize: ResStyle.medium_font,
                      color: LOGO_COLOR,
                    ),
                  ),
                ],
                SizedBox(height: 0.5 * ResStyle.spacing),
                Text(
                  'RM ${asset.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: ResStyle.body_font,
                    color: LOGO_COLOR,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(ResStyle.spacing / 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: HIGHTLIGHT_COLOR,
              size: ResStyle.spacing * 2,
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

  color = paid ? RM5_COLOR : TITLE_COLOR;
  return Padding(
     padding:  EdgeInsets.symmetric(vertical: ResStyle.spacing/2),
    child: GestureDetector(
      onTap: () => func(),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.8),
                
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            // boxShadow: [
            //   BoxShadow(
            //     color: color.withOpacity(0.3),
            //     blurRadius: 15,
            //     offset: Offset(0, 8),
            //   ),
            // ],
          ),
          padding: EdgeInsets.all(ResStyle.spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Debt Name
                    Text(
                      debt.name,
                      style: TextStyle(
                        fontSize: ResStyle.body_font,
                        fontWeight: FontWeight.bold,
                        color: HIGHTLIGHT_COLOR,
                      ),
                    ),
                    if (debt.desc != null && debt.desc!.isNotEmpty) ...[
                      SizedBox(height: ResStyle.spacing / 2),
                      Text(
                        debt.desc! + ((debt.remaining_month == -1)?'':"\nRemaining ${debt.remaining_month} months"),
                        style: TextStyle(
                          fontSize: ResStyle.medium_font,
                          color: HIGHTLIGHT_COLOR.withOpacity(0.8),
                        ),
                      ),
                    ]else if(debt.remaining_month != -1)...[
                       SizedBox(height: ResStyle.spacing / 2),
                      Text(
                        "Remaining ${debt.remaining_month} months",
                        style: TextStyle(
                          fontSize: ResStyle.medium_font,
                          color: HIGHTLIGHT_COLOR.withOpacity(0.8),
                        ),
                      ),
                    ],
                    SizedBox(height: ResStyle.spacing / 2),
                    // Monthly Payment
                    Text(
                      'RM ${debt.monthly_payment.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: ResStyle.body_font,
                        fontWeight: FontWeight.bold,
                        color: HIGHTLIGHT_COLOR,
                      ),
                    ),
                  ],
                ),
              ),
              if (paid)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: HIGHTLIGHT_COLOR,
                      size: 3 * ResStyle.spacing,
                    ),
                    SizedBox(height: ResStyle.spacing / 2),
                    Text(
                      FormatterHelper.dateFormat(debt.last_payment_date!),
                      style: TextStyle(
                        fontSize: ResStyle.body_font,
                        color: HIGHTLIGHT_COLOR,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}


Widget ExpenseDetailCard(
  Debt debt,
  VoidCallback func,
) {
  Color color = (debt.month_total_expense > debt.alarming_limit &&
          debt.alarming_limit > 0)
      ? DANGER_COLOR
      : TITLE_COLOR;

  return Padding(
    padding:  EdgeInsets.symmetric(vertical: ResStyle.spacing/2),
    child: GestureDetector(
      onTap: () => func(),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
         
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            // boxShadow: [
            //   BoxShadow(
            //     color: color.withOpacity(0.3),
            //     blurRadius: 15,
            //     offset: Offset(0, 8),
            //   ),
            // ],
          ),
          padding: EdgeInsets.all(ResStyle.spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      debt.name,
                      style: TextStyle(
                        fontSize: ResStyle.body_font,
                        fontWeight: FontWeight.bold,
                        color: HIGHTLIGHT_COLOR,
                      ),
                    ),
                    if (debt.desc != null && debt.desc!.isNotEmpty) ...[
                      SizedBox(height: ResStyle.spacing / 2),
                      Text(
                        debt.desc!,
                        style: TextStyle(
                          fontSize: ResStyle.medium_font,
                          color: HIGHTLIGHT_COLOR.withOpacity(0.8),
                        ),
                      ),
                    ],
                    SizedBox(height: ResStyle.spacing / 2),
                    // Monthly Total Expense and Date
                    Row(
                      children: [
                        Text(
                          "${FormatterHelper.toDoubleString(debt.month_total_expense)}",
                          style: TextStyle(
                            fontSize: ResStyle.body_font,
                            fontWeight: FontWeight.bold,
                            color: HIGHTLIGHT_COLOR,
                          ),
                        ),
                        SizedBox(width: ResStyle.spacing),
                        Container(
                          decoration: BoxDecoration(
                            color: HIGHTLIGHT_COLOR,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: ResStyle.spacing / 2,
                            vertical: ResStyle.spacing / 4,
                          ),
                          child: Text(
                            '${FormatterHelper.getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                            style: TextStyle(
                              fontSize: ResStyle.font,
                              fontWeight: FontWeight.bold,
                              color: TITLE_COLOR,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResStyle.spacing / 4),
                    // Alarming Limit and Total Spending
                    if (debt.alarming_limit > 0)
                      Text(
                        debt.month_total_expense > debt.alarming_limit
                            ? 'Limit: ${FormatterHelper.toDoubleString(debt.alarming_limit)} (Over ${(100 * ((debt.month_total_expense.abs() / debt.alarming_limit.abs()) - 1)).toStringAsFixed(1)}%)'
                            : 'Limit: ${FormatterHelper.toDoubleString(debt.alarming_limit)} (Used ${(100 * (debt.month_total_expense.abs() / debt.alarming_limit.abs())).toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: ResStyle.small_font,
                          color: HIGHTLIGHT_COLOR,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      'Total Spending: ${FormatterHelper.toDoubleString(debt.total_expense)}',
                      style: TextStyle(
                        fontSize: ResStyle.small_font,
                        color: HIGHTLIGHT_COLOR,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

Widget CardWidgetivider(String title, Widget trailing,
    {bool isLast = false, GlobalKey? key}) {
  return Column(
    children: [
      Padding(
        key: key,
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
                    maxLines: 4,
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
          't${widget.transaction.id}_${UserToken.user_code?.substring(10)}$extension');

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
            ScaffoldMessenger.of(context)
          .showSnackBar(BugSnackBar('Add Transaction Proof Successfully!', 3));
        } catch (e) {}
      }

    
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
            additionHeight: -ResStyle.height * 0.15,
            header: 'Transaction',
            widgets: [
              BugTextInput(
                controller: _noteController,
                label: 'Transaction Note',
                hint: 'Enter your note',
                prefixIcon: Icon(Icons.note_alt),
              ),
              SizedBox(
                height: ResStyle.spacing * 3,
              ),
              BugPrimaryButton(
                  text: 'Save Note',
                  color: TITLE_COLOR,
                  onPressed: () {
                    _saveNote(_noteController.text);
                   // Navigator.of(context).pop();
                  }),
              SizedBox(
                height: ResStyle.spacing,
              ),
              BugPrimaryButton(
                  text: 'Delete This Transaction',
                  color: DANGER_COLOR,
                  onPressed: () {
                     showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return BugInfoDialog(
                                              title: 'Delete Confirmation',
                                              main_color:
                                                  DANGER_COLOR, // Set a color for the delete confirmation
                                              message:
                                                  'Are you sure you want to delete this message"?',
                                              actions: [
                                                BugPrimaryButton(
                                                    onPressed: () async {
                                                     _deleteNote();
                                                    },
                                                    text: 'Delete',
                                                    color: DANGER_COLOR),
                                                SizedBox(
                                                  height: ResStyle.spacing,
                                                ),
                                                BugPrimaryButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    text: 'Cancel',
                                                    color: PRIMARY_COLOR),
                                              ],
                                            );
                                          },
                                        );
                   
                  }),
              SizedBox(
                height: ResStyle.spacing / 2,
              ),
              Text(
                '**Deleting a transaction will not restore the values of assets and debts. To roll back the effect of the transaction, You can restore from the current backup available on the profile page.**',
                style: TextStyle(
                  fontSize: ResStyle.small_font,
                  color: DANGER_COLOR,
                ),
                maxLines: 4,
                textAlign: TextAlign.center,
              )
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
        margin: EdgeInsets.only(bottom: ResStyle.spacing),
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
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.transaction.asset != null)
                      Text('From: ${widget.transaction.asset!.name}',
                          style: TextStyle(color: TITLE_COLOR)),
                    if (widget.transaction.debt != null)
                      Text('For: ${widget.transaction.debt!.name}',
                          style: TextStyle(color: TITLE_COLOR)),
                    Text('Note: ${widget.transaction.desc}',
                        style: TextStyle(color: TITLE_COLOR)),
                    Text(
                        'Date: ${widget.transaction.created_at.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: PRIMARY_COLOR)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      FormatterHelper.toDoubleString(widget.transaction.amount),
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (widget.transaction.amount >= 0)
                              ? Colors.green
                              : Colors.red),
                    ),
                    BugSmallButton(
                      text: proofExists ? 'View Proof' : 'Add Proof',
                      onPressed: proofExists ? viewProof : addProof,
                      color: proofExists ? SUCCESS_COLOR : TITLE_COLOR,
                      borderRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildContentCard(content, Function func) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: ResStyle.spacing / 2),
    child: Card(
      //color: RM20_COLOR.withOpacity(0.8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          gradient: LinearGradient(
              colors: [
                RM20_COLOR.withOpacity(0.8),
                RM20_COLOR.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        ),
        constraints: BoxConstraints(minHeight: ResStyle.height * 0.15,),
          
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(ResStyle.spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.name,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: ResStyle.medium_font,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResStyle.spacing),
                        Text(
                          content.desc,
                          maxLines: 4,
                          style: TextStyle(fontSize: ResStyle.small_font),
                        ),
                        SizedBox(height: ResStyle.spacing / 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BugRoundButton(
              icon: Icons.chevron_right_rounded,
              onPressed: () => func(),
            ),
            SizedBox(width: ResStyle.spacing),
          ],
        ),
      ),
    ),
  );
}
