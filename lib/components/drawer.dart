import 'package:connect/provider/auth_provider.dart';
import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DrawerComponent extends StatelessWidget {
  final Function setPage;
  const DrawerComponent(this.setPage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 120,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          color: AppColors.primaryColorHover,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Conecte-se com carinho',
                        style: TextStyle(
                          color: AppColors.textColorSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.solidHouse,
              color: AppColors.textColorSecondary,
            ),
            title: Text(
              'Início',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              setPage("home");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.message,
              color: AppColors.textColorSecondary,
            ),
            title: Text(
              'Chat',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              setPage("chat");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.arrowUp91,
              color: AppColors.textColorSecondary,
            ),
            title: Text(
              'Contadores',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setPage("counters");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.locationArrow,
              color: AppColors.textColorSecondary,
            ),
            title: Text(
              'Distância',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setPage("location");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.timeline,
              color: AppColors.textColorSecondary,
            ),
            title: Text(
              'Linha do Tempo',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setPage("timeline");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.heart,
              color: AppColors.textColorSecondary,
            ),
            title: Text(
              'Linguagem do Amor',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setPage("lovelanguage");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.spotify,
              color: AppColors.textColorSecondary,
            ),
            title: Text(
              'Música Dedicada',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setPage("spotify");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.userAstronaut,
              color: AppColors.infoColor,
            ),
            title: Text(
              'Dados e Perfil',
              style: TextStyle(
                color: AppColors.infoColorHover,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setPage("settings");
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.rightFromBracket,
              color: AppColors.errorColor,
            ),
            title: Text(
              'Sair',
              style: TextStyle(
                color: AppColors.errorColorHover,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              context.read<AuthProvider>().logoutUser();
            },
          ),
        ],
      ),
    );
  }
}
