import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData appTheme = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppColors.backgroundColor,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: "Montserrat"),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
      ),
    ),
    cardTheme: CardThemeData(color: AppColors.cardBackgroundColor),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.drawerBackgroundColor,
    ),
  );
}
