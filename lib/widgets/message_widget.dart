import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';

class MessageComponent extends StatelessWidget {
  final String text;
  final String date;
  final Alignment alignment;

  const MessageComponent(
    this.text,
    this.date, {
    required this.alignment,
    super.key,
  });

  BorderRadius getBorderRadius() {
    if (alignment == Alignment.centerLeft) {
      return BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      );
    }
  }

  Color color() {
    if (alignment == Alignment.centerLeft) {
      return AppColors.secondaryColorHover;
    } else {
      return AppColors.primaryColorHover;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: color(),
        borderRadius: getBorderRadius(),
      ),
      child: IntrinsicWidth(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: AppColors.drawerBackgroundColor,
            fontWeight: FontWeight.w500,
          ),
          ),
          const SizedBox(height: 6),
          Align(
          alignment: Alignment.centerRight,
          child: Text(
            date,
            style: TextStyle(
            color: AppColors.backgroundColor,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            ),
          ),
          ),
        ],
        ),
      ),
      ),
    );
  }
}
