import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class DataCard extends StatelessWidget {
  final String text;
  final String value;
  final String description;
  final IconData icon;
  final int type;
  final Function execPlus;
  final Function execMinus;
  final String lastUpdate;

  const DataCard({
    required this.text,
    required this.value,
    required this.description,
    required this.icon,
    required this.execPlus,
    required this.execMinus,
    this.lastUpdate = '',
    this.type = 0,
    super.key,
  });

  Color get cardColor {
    if (type == 1) {
      return AppColors.primaryColor;
    } else if (type == 2) {
      return AppColors.secondaryColor;
    }

    return AppColors.cardBackgroundColor;
  }

  Color get textColor {
    if (type == 2) {
      return AppColors.drawerBackgroundColor;
    }

    return AppColors.textColor;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: cardColor,
        child: Padding(
          padding: EdgeInsets.all(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 32,
                          height: 1,
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.5,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  FaIcon(icon, size: 64, color: textColor),
                ],
              ),
              SizedBox(height: 20),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (lastUpdate.isNotEmpty)
                Text(
                  DateFormat('dd MMM y').format(DateTime.parse(lastUpdate)),
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withAlpha(50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              SizedBox(height: 16),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async => await execPlus(),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          AppColors.backgroundColor,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.plus,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async => execMinus(),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          AppColors.backgroundColor,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.minus,
                        color: AppColors.textColor,
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
}
