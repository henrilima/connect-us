import 'package:connect/components/header.dart';
import 'package:connect/data/love_language_data.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/services/messenger_service.dart';
import 'package:flutter/material.dart';

class LoveLanguageQuiz extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const LoveLanguageQuiz(this.setPage, {required this.userData, super.key});

  @override
  State<LoveLanguageQuiz> createState() => _LoveLanguageQuizState();
}

class _LoveLanguageQuizState extends State<LoveLanguageQuiz> {
  List<LoveLanguageOption> answers = [];
  int index = 0;

  void _answerQuestion(LoveLanguageOption option) {
    answers.add(option);
    if (index < loveQuestions.length - 1) {
      setState(() {
        index++;
      });
    } else {
      final results = calculatePercentages(answers);
      _showResultsDialog(context, results);
    }
  }

  Future<void> _showResultsDialog(
    BuildContext context,
    Map<String, double> results,
  ) async {
    await DatabaseService().setUserLoveLanguage(widget.userData['userId'], {
      'palavras_de_afirmacao': results['palavras_de_afirmacao'].toString(),
      'tempo_de_qualidade': results['tempo_de_qualidade'].toString(),
      'presentes': results['presentes'].toString(),
      'atos_de_servico': results['atos_de_servico'].toString(),
      'toque_fisico': results['toque_fisico'].toString(),
    });

    if (!context.mounted) return;

    if (context.mounted) {
      AppMessenger(
        context,
        "Seu resultado foi salvo, você pode conferir ele no ícone de receita.",
        "success",
      ).show();
    }

    await Future.delayed(const Duration(milliseconds: 100));

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Map<String, double> calculatePercentages(
    List<LoveLanguageOption> selectedOptions,
  ) {
    final Map<String, int> totals = {
      'palavras_de_afirmacao': 0,
      'tempo_de_qualidade': 0,
      'presentes': 0,
      'atos_de_servico': 0,
      'toque_fisico': 0,
    };

    for (final option in selectedOptions) {
      option.scores.forEach((key, value) {
        if (totals.containsKey(key)) {
          totals[key] = totals[key]! + value;
        }
      });
    }

    final int sum = totals.values.fold(0, (a, b) => a + b);

    if (sum == 0) {
      return totals.map((k, v) => MapEntry(k, 0.0));
    }
    return totals.map((k, v) => MapEntry(k, (v * 100) / sum));
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = loveQuestions[index];
    final progress = (index + 1) / loveQuestions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: 'Quiz de Linguagens'),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.drawerBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 6,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Questão ${index + 1} de ${loveQuestions.length}',
                      style: TextStyle(
                        color: AppColors.textColorSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    ...currentQuestion.options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ElevatedButton(
                          onPressed: () => _answerQuestion(option),
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.drawerBackgroundColor,
                                foregroundColor: AppColors.textColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                              ).copyWith(
                                overlayColor: WidgetStateProperty.all(
                                  AppColors.primaryColor.withAlpha(26),
                                ),
                              ),
                          child: Text(
                            option.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
