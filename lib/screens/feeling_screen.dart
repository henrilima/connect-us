import 'package:connect/components/header.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/fade_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connect/services/api_service.dart';

class FeelingScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;

  const FeelingScreen(this.setPage, {super.key, required this.userData});

  @override
  State<FeelingScreen> createState() => _FeelingScreenState();
}

class _FeelingScreenState extends State<FeelingScreen> {
  final List<Map<String, dynamic>> _reactions = [
    {
      'label': 'Feliz',
      'action': 'Isso não é bom?',
      'icon': FontAwesomeIcons.faceSmile,
      'color': 0xFF4CAF50,
    },
    {
      'label': 'Apaixonado',
      'action': 'O amor é mesmo lindo.',
      'icon': FontAwesomeIcons.faceGrinHearts,
      'color': 0xFFE91E63,
    },
    {
      'label': 'Triste',
      'action': 'Talvez ele(a) precise de ajuda, tente ser compreensivo.',
      'icon': FontAwesomeIcons.faceSadTear,
      'color': 0xFF2196F3,
    },
    {
      'label': 'Cansado',
      'action': '',
      'icon': FontAwesomeIcons.faceTired,
      'color': 0xFF9E9E9E,
    },
    {
      'label': 'Bravo',
      'action': 'Algo tenso deve ter acontecido...',
      'icon': FontAwesomeIcons.faceAngry,
      'color': 0xFFF44336,
    },
    {
      'label': 'Doente',
      'action': 'Isso não é bom, tente ajudá-lo(a) como puder.',
      'icon': FontAwesomeIcons.faceDizzy,
      'color': 0xFF8BC34A,
    },
    {
      'label': 'Ansioso',
      'action': 'Ansioso por algo bom ou ruim? Não sei, mas é bom ajudá-lo(a).',
      'icon': FontAwesomeIcons.faceGrimace,
      'color': 0xFFFF9800,
    },
    {
      'label': 'Entediado',
      'action': 'Que tal jogar um pouco de jo-ken-pô?',
      'icon': FontAwesomeIcons.faceMeh,
      'color': 0xFF607D8B,
    },
    {
      'label': 'Animado',
      'action': 'Algo bom parece estar acontecendo.',
      'icon': FontAwesomeIcons.faceGrinStars,
      'color': 0xFFFFC107,
    },
  ];

  Map<String, dynamic>? _myFeeling;

  @override
  void initState() {
    super.initState();
    _loadMyFeeling();
  }

  void _loadMyFeeling() async {
    final userData = await DatabaseService().getUserData(
      widget.userData['userId'],
    );

    if (userData.containsKey('feeling')) {
      setState(() {
        _myFeeling = Map<String, dynamic>.from(userData['feeling']);
      });
    }
  }

  void _updateFeeling(Map<String, dynamic> reaction) async {
    if (_myFeeling != null && _myFeeling!['label'] == reaction['label']) {
      setState(() {
        _myFeeling = null;
      });

      await DatabaseService().updateUserFeeling(
        widget.userData['userId'],
        'Neutro',
        FontAwesomeIcons.faceMehBlank.codePoint,
        0xFF9E9E9E,
      );
      return;
    }

    setState(() {
      _myFeeling = reaction;
    });

    await DatabaseService().updateUserFeeling(
      widget.userData['userId'],
      reaction['label'],
      (reaction['icon'] as IconData).codePoint,
      reaction['color'],
    );

    final negativeFeelings = [
      'Triste',
      'Cansado',
      'Bravo',
      'Doente',
      'Ansioso',
    ];

    final partnerId = widget.userData['partnerId'];
    final token = await DatabaseService().getMessagerToken(partnerId);
    final myName = widget.userData['username'] ?? 'Seu amor';

    if (negativeFeelings.contains(reaction['label'])) {
      if (token != null) {
        await ApiService().sendNotification(
          token,
          "Poxa",
          "$myName está se sentindo ${reaction['label']}. ${reaction['action']}",
        );
      }
    } else {
      if (token != null) {
        await ApiService().sendNotification(
          token,
          "Hehe",
          "$myName está se sentindo ${reaction['label']}. ${reaction['action']}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: 'Sentimentos'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPartnerStatus(),
                    const SizedBox(height: 32),
                    Text(
                      "Como você está se sentindo?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _reactions.length,
                      itemBuilder: (context, index) {
                        final reaction = _reactions[index];
                        final isSelected =
                            _myFeeling != null &&
                            _myFeeling!['label'] == reaction['label'];

                        return FadeIn(
                          delay: Duration(milliseconds: index * 50),
                          child: _buildReactionCard(reaction, isSelected),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerStatus() {
    return StreamBuilder(
      stream: DatabaseService().getPartnerStream(widget.userData['partnerId']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final feeling =
            data['feeling'] ??
            {'label': 'Neutro', 'icon': 0xf11a, 'color': 0xFF9E9E9E};

        final iconData = IconData(
          feeling['icon'],
          fontFamily: 'FontAwesomeSolid',
          fontPackage: 'font_awesome_flutter',
        );
        final color = Color(feeling['color']);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.drawerBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withAlpha(77), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(26),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "Seu par está se sentindo:",
                style: TextStyle(
                  color: AppColors.textColorSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Icon(iconData, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                feeling['label'],
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionCard(Map<String, dynamic> reaction, bool isSelected) {
    final color = Color(reaction['color']);

    return GestureDetector(
      onTap: () => _updateFeeling(reaction),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(51)
              : AppColors.drawerBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(77),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              reaction['icon'],
              size: 32,
              color: isSelected ? color : AppColors.textColorSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              reaction['label'],
              style: TextStyle(
                color: isSelected ? color : AppColors.textColorSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
