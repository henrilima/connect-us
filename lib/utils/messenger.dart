import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';

class AppMessenger {
  final String text;
  final String type;
  final int duration;
  final BuildContext context;

  const AppMessenger(this.context, this.text, this.type, {this.duration = 5});

  Color get color {
    switch (type) {
      case 'error':
        return AppColors.errorColor;
      case 'success':
        return AppColors.successColor;
      case 'warning':
        return AppColors.warningColor;
      case 'info':
        return AppColors.infoColor;
      default:
        return AppColors.primaryColor;
    }
  }

  Color get textColor {
    switch (type) {
      case 'success':
      case 'warning':
      case 'info':
        return AppColors.drawerBackgroundColor;
      default:
        return AppColors.textColor;
    }
  }

  void show() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
        duration: Duration(seconds: duration),
        backgroundColor: color,
      ),
    );
  }
}
