import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/data/love_language_data.dart'; // Mantido
import 'package:connect/forms/love_language_quiz.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/dialoguer.dart'; // Mantido
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/language_card.dart'; // Mantido
import 'package:connect/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Mantido
import 'package:rxdart/rxdart.dart';

class LoveLanguageScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function setPage;
  const LoveLanguageScreen(this.setPage, {required this.userData, super.key});

  @override
  State<LoveLanguageScreen> createState() => _LoveLanguageScreenState();
}

class _LoveLanguageScreenState extends State<LoveLanguageScreen> {
  bool _isFirstLoad = true;

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

  String _getMainText(
    Map<String, String>? userLovel,
    Map<String, String>? partnerLovel,
  ) {
    if (userLovel == null || userLovel.isEmpty) {
      if (partnerLovel != null && partnerLovel.isNotEmpty) {
        return "O seu par já respondeu ao questionário, só falta você, hein! Responda agora:";
      }
      return "Responda ao questionário para descobrir como você prefere receber e demonstrar afeto. Esses resultados ficarão disponíveis para o seu par quando ambos responderem.";
    } else if (partnerLovel == null || partnerLovel.isEmpty) {
      return "O seu resultado nós já sabemos. Agora incentive seu par a descobrir a linguagem do amor dele.";
    }
    return "";
  }

  Stream<Map<String, Map<String, String>?>> _combinedLoveLanguages() {
    final Stream<Map<String, String>> streamUser = DatabaseService()
        .streamUserLoveLanguages(widget.userData['userId']);
    final Stream<Map<String, String>> streamPartner = DatabaseService()
        .streamUserLoveLanguages(widget.userData['partnerId']);

    return Rx.combineLatest2(streamUser, streamPartner, (
      userLovel,
      partnerLovel,
    ) {
      return {'user': userLovel, 'partner': partnerLovel};
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Map<String, String>?>>(
      stream: _combinedLoveLanguages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            _isFirstLoad) {
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isFirstLoad = false);
              }
            });
          }
          if (_isFirstLoad) return const Loading();
        }

        if (snapshot.hasError) {
          return ErrorScreenComponent("${snapshot.error}");
        }

        final data = snapshot.data!;
        final userLovel = data['user'];
        final partnerLovel = data['partner'];

        if (_isComplete(userLovel, partnerLovel)) {
          // Chamando a nova função para dados completos
          return _completeData(userLovel!, partnerLovel!);
        } else {
          return _notCompleteData(userLovel, partnerLovel);
        }
      },
    );
  }

  // Novo método para dados completos (antigo LoveLanguageComponent)
  Widget _completeData(
    Map<String, String> userLovel,
    Map<String, String> partnerLovel,
  ) {
    // Adicionando uma Key para garantir a reatividade na transição.
    return Scaffold(
      key: const ValueKey('LoveLanguageResults'), // CHAVE DE REATIVIDADE
      appBar: AppBarComponent(
        '',
        actions: [
          IconButton(
            onPressed: () {
              final userSortedLovel =
                  userLovel.entries.map((e) {
                    final score = double.tryParse(e.value) ?? 0.0;
                    return {'key': e.key, 'value': score};
                  }).toList()..sort(
                    (a, b) =>
                        (b['value'] as double).compareTo(a['value'] as double),
                  );

              Dialoguer.showCustomAlert(
                context: context,
                titleWidget: Text(
                  'Sua linguagem do amor',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColorHover,
                  ),
                ),
                contentWidget: Column(
                  mainAxisSize:
                      MainAxisSize.min, // ESSENCIAL PARA O TAMANHO DO MODAL
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...userSortedLovel.map((item) {
                      final key = item['key'] as String;
                      final value = (item['value'] as double).toStringAsFixed(
                        0,
                      );
                      final details = loveLanguageDetails[key]!;

                      return Text.rich(
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        TextSpan(
                          children: [
                            TextSpan(text: '${details['name']}: '),
                            TextSpan(text: '$value%'),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                buttonText: 'Certo',
              );
            },
            icon: const FaIcon(FontAwesomeIcons.receipt),
            iconSize: 20,
          ),
          IconButton(
            onPressed: () {
              // Navegar para o quiz (rota separada, conforme solicitado)
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
      drawer: DrawerComponent(widget.setPage),
      body: _buildCompleteBody(partnerLovel, userLovel),
    );
  }

  // Widget auxiliar para construir o corpo de _completeData
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

    return SingleChildScrollView(
      child: Padding(
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
                    text: "As melhores maneiras de demonstrar carinho para ",
                  ),
                  TextSpan(
                    text: widget.userData['partnerId'],
                    style: const TextStyle(color: AppColors.primaryColorHover),
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
                final value = (item['value'] as double).toStringAsFixed(0);
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
              "Aprofunde-se nas 3 linguagens mais altas:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColorHover,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedLovel.take(3).map((item) {
              final key = item['key'] as String;
              final details = loveLanguageDetails[key]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: LoveLanguageInfoCard(
                  title: details['name'] as String,
                  color: details['color'] as Color,
                  whatIs: details['what_is'] as String,
                  howToShow: details['how_to_show'] as String,
                  practicalExamples: details['practical_examples'] as String,
                  needWhenStressed: details['needs_when_stressed'] as String,
                  toAvoid: details['to_avoid'] as String,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Método original para dados incompletos
  Widget _notCompleteData(
    Map<String, String>? userLovel,
    Map<String, String>? partnerLovel,
  ) {
    // Adicionando uma Key para garantir a reatividade na transição.
    return Scaffold(
      key: const ValueKey('LoveLanguageForm'), // CHAVE DE REATIVIDADE
      appBar: AppBarComponent('Linguagem do Amor'),
      drawer: DrawerComponent(widget.setPage),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Image.asset('assets/images/potion.png'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    "Qual é a sua linguagem do amor?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMainText(userLovel, partnerLovel),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_hasUserData(userLovel))
                    ElevatedButton(
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          "Iniciar questionário",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
