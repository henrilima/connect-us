import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final String type;

  const AppBarComponent(
    this.title, {
    this.type = 'drawer',
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColorHover,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.backgroundColor,
      leading: Builder(
        builder: (context) {
          if (type == "back") {
            return IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
            );
          } else {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: FaIcon(FontAwesomeIcons.barsStaggered, size: 20),
            );
          }
        },
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
