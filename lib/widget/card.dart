import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:flutter/material.dart';

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
  return Wrap(
    children: [
      ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: ResStyle.medium_font),
          ),
          trailing: trailing),
      if (!isLast) const Divider(),
    ],
  );
}
