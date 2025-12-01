import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PagesComponent extends StatelessWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const PagesComponent(this.setPage, this.userData, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          padding: const EdgeInsets.only(bottom: 124.0),
          children: [
            _buildCardItem(
              icon: FontAwesomeIcons.message,
              title: 'Chat',
              color: const Color(0xFF64B5F6), // Azul Suave
              onTap: () => setPage("chat"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.camera,
              color: const Color(0xFFEC407A), // Rosa
              title: 'Registro Único',
              onTap: () => setPage("daily_photos"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.faceSmileWink,
              color: const Color.fromARGB(255, 234, 209, 86), // Amarelo
              title: 'Como se sente?',
              onTap: () => setPage("feeling"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.arrowUp91,
              title: 'Contadores',
              color: const Color(0xFF9575CD), // Roxo Suave
              onTap: () => setPage("counters"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.locationArrow,
              color: const Color(0xFF4DB6AC), // Verde Água
              title: 'Distância em tempo real',
              onTap: () => setPage("location"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.timeline,
              title: 'Linha do Tempo',
              color: const Color(0xFFFFB74D), // Laranja Suave
              onTap: () => setPage("timeline"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.solidHeart,
              color: const Color(0xFFE57373), // Vermelho Suave
              title: 'Linguagem do Amor',
              onTap: () => setPage("lovelanguage"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.listCheck,
              color: const Color(0xFF29B6F6), // Azul Claro
              title: 'Momentos',
              onTap: () => setPage("moments"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.spotify,
              color: const Color(0xFF1DB954), // Verde Spotify
              title: 'Música Dedicada',
              onTap: () => setPage("spotify"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.handScissors,
              color: const Color(0xFFAED581), // Verde Claro
              title: 'Pedra, Papel e Tesoura',
              onTap: () => setPage("rps"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.gift,
              color: const Color(0xFFBA68C8), // Magenta Suave
              title: 'Surpresas',
              onTap: () => setPage("surprises"),
            ),
            _buildCardItem(
              icon: FontAwesomeIcons.trophy,
              color: const Color(0xFFFFD54F), // Âmbar/Dourado
              title: 'Hall de Conquistas',
              onTap: () => setPage("achievements"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Color? textColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                icon,
                size: 32,
                color: color ?? AppColors.textColorSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: textColor ?? AppColors.textColorSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
