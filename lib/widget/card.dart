import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';

Widget AssetCard(
  String header,
  String text,
  Function() func, {
  Color color = RM1_COLOR,
  Color font_color = TEXT_COLOR  // Default color
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
        padding:  EdgeInsets.all(ResStyle.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: HIGHTLIGHT_COLOR),
                SizedBox(width: 0.5* ResStyle.spacing),
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
              style:  TextStyle(
                fontSize: ResStyle.header_font,
                fontWeight: FontWeight.bold,
                color: font_color
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget GeneralCard(String text, Function() func) {
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
                'Total Debts/Bills',
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
