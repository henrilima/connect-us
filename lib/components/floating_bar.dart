import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomFloatingBar extends StatelessWidget {
  final Function setPage;
  final int selectedIndex;
  final Function(int) onTabChanged;

  const BottomFloatingBar(
    this.setPage, {
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80 * 3,
      decoration: BoxDecoration(
        color: AppColors.textColor.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildButton(icon: FontAwesomeIcons.solidHouse, index: 0),
          _buildButton(icon: FontAwesomeIcons.qrcode, index: 1),
          _buildButton(icon: FontAwesomeIcons.link, index: 2),
        ],
      ),
    );
  }

  // BOTÃO INDIVIDUAL
  Widget _buildButton({required IconData icon, required int index}) {
    bool isSelected = index == selectedIndex;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onTabChanged(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.drawerBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: FaIcon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 28,
          ),
        ),
      ),
    );
  }
}
