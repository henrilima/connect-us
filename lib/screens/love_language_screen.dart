import 'package:connect/components/header.dart';
import 'package:connect/data/love_language_data.dart';
import 'package:connect/forms/love_language_quiz.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

class LoveLanguageScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function setPage;
  const LoveLanguageScreen(this.setPage, {required this.userData, super.key});

  @override
  State<LoveLanguageScreen> createState() => _LoveLanguageScreenState();
}

class _LoveLanguageScreenState extends State<LoveLanguageScreen> {
  Map<String, String>? _usernames;

  bool _isComplete(
    Map<String, String>? userLovel,
    Map<String, String>? partnerLovel,
  ) {
    return userLovel != null &&
        userLovel.isNotEmpty &&
        partnerLovel != null &&
        partnerLovel.isNotEmpty;
  }

  bool _hasUserData(Map<String, String>? userLovel) {
    return userLovel != null && userLovel.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadUsernames();
  }

  Future<void> _loadUsernames() async {
    final authorUsername = await DatabaseService().getUsername(
      widget.userData['userId'],
    );
    final partnerUsername = await DatabaseService().getUsername(
      widget.userData['partnerId'],
    );

    setState(() {
      _usernames = {'author': authorUsername, 'partner': partnerUsername};
    });
  }

  String _resolveMainText(
    Map<String, String>? userLovel,
    Map<String, String>? partnerLovel,
  ) {
    if (userLovel == null || userLovel.isEmpty) {
      if (partnerLovel != null && partnerLovel.isNotEmpty) {
        return "O seu par já respondeu ao questionário, só falta você, hein! Responda agora:";
      }
      return "Responda ao questionário para descobrir como você prefere receber e demonstrar afeto. Esses resultados ficarão disponíveis para o seu par quando ambos responderem.";
    } else if (userLovel.isNotEmpty &&
        (partnerLovel == null || partnerLovel.isEmpty)) {
      return "O seu resultado nós já sabemos. Agora incentive seu par a descobrir a linguagem do amor dele.";
    }
    return "Tudo pronto! Vocês já descobriram as linguagens do amor.";
  }

  Stream<Map<String, Map<String, String>?>> _combinedLoveLanguages() {
    final streamUser = DatabaseService().streamUserLoveLanguages(
      widget.userData['userId'],
    );
    final streamPartner = DatabaseService().streamUserLoveLanguages(
      widget.userData['partnerId'],
    );

    return Rx.combineLatest2<
      Map<String, String>?,
      Map<String, String>?,
      Map<String, Map<String, String>?>
    >(
      streamUser,
      streamPartner,
      (user, partner) => {'user': user, 'partner': partner},
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Map<String, String>?>>(
      stream: _combinedLoveLanguages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || _usernames == null) {
          return const Loading();
        }

        if (snapshot.hasError) {
          return ErrorScreenComponent("${snapshot.error}");
        }

        final data = snapshot.data!;
        final userLovel = data['user'];
        final partnerLovel = data['partner'];

        if (_isComplete(userLovel, partnerLovel)) {
          return _completeData(userLovel!, partnerLovel!);
        } else {
          return _notCompleteData(userLovel, partnerLovel);
        }
      },
    );
  }

  Widget _completeData(
    Map<String, String> userLovel,
    Map<String, String> partnerLovel,
  ) {
    return Scaffold(
      key: const ValueKey('LoveLanguageResults'),
      body: _buildCompleteBody(partnerLovel, userLovel),
    );
  }

  Widget _buildCompleteBody(
    Map<String, String> partnerLovel,
    Map<String, String> userLovel,
  ) {
    final sortedLovel =
        partnerLovel.entries.map((e) {
          final score = double.tryParse(e.value) ?? 0.0;
          return {'key': e.key, 'value': score};
        }).toList()..sort(
          (a, b) => (b['value'] as double).compareTo(a['value'] as double),
        );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
              widget.setPage,
              true,
              title: "Linguagem",
              actions: [
                IconButton(
                  onPressed: () {
                    final userSortedLovel =
                        userLovel.entries.map((e) {
                          final score = double.tryParse(e.value) ?? 0.0;
                          return {'key': e.key, 'value': score};
                        }).toList()..sort(
                          (a, b) => (b['value'] as double).compareTo(
                            a['value'] as double,
                          ),
                        );

                    Dialoguer.openModalBottomSheet(
                      context: context,
                      customLayout: true,
                      form: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                'Sua linguagem do amor',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColorHover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...userSortedLovel.map((item) {
                              final key = item['key'] as String;
                              final value = (item['value'] as double)
                                  .toStringAsFixed(0);
                              final details = loveLanguageDetails[key]!;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: details['color'] as Color,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${details['name']}:',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '$value%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textColorSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.receipt),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LoveLanguageQuiz(
                          widget.setPage,
                          userData: widget.userData,
                        ),
                      ),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.rotateRight),
                  iconSize: 20,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              "As melhores maneiras de demonstrar carinho para ",
                        ),
                        TextSpan(
                          text: _usernames!['partner'],
                          style: const TextStyle(
                            color: AppColors.primaryColorHover,
                          ),
                        ),
                        const TextSpan(text: ":"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedLovel.map((item) {
                      final key = item['key'] as String;
                      final value = (item['value'] as double).toStringAsFixed(
                        0,
                      );
                      final details = loveLanguageDetails[key]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: details['color'] as Color,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${details['name']}:',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$value%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Aprofunde-se nas linguagens:",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sortedLovel.map((item) {
                    final key = item['key'] as String;
                    final details = loveLanguageDetails[key]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (details['color'] as Color).withAlpha(77),
                            width: 1,
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (details['color'] as Color).withAlpha(
                                  26,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.heart,
                                color: details['color'] as Color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              details['name'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoSection(
                                      "O que é?",
                                      details['what_is'] as String,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoSection(
                                      "Como demonstrar?",
                                      details['how_to_show'] as String,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoSection(
                                      "O que evitar?",
                                      details['to_avoid'] as String,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notCompleteData(
    Map<String, String>? userLovel,
    Map<String, String>? partnerLovel,
  ) {
    final mainText = _resolveMainText(userLovel, partnerLovel);

    return Scaffold(
      key: const ValueKey('LoveLanguageForm'),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: "Linguagem"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/potion.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Descubra o Amor",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mainText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColorSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (!_hasUserData(userLovel))
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoveLanguageQuiz(
                                  widget.setPage,
                                  userData: widget.userData,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColorHover,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Iniciar Questionário",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
