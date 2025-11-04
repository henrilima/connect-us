import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/data/love_language_data.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/messenger.dart';
import 'package:flutter/material.dart';

class LoveLanguageQuiz extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const LoveLanguageQuiz(this.setPage, {required this.userData, super.key});

  @override
  State<LoveLanguageQuiz> createState() => _LoveLanguageQuizState();
}

class _LoveLanguageQuizState extends State<LoveLanguageQuiz> {
  List<int> answers = [];
  int index = 0;

  void _answerQuestion(int selectedOptionIndex) {
    answers.add(selectedOptionIndex);
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

  Map<String, double> calculatePercentages(List<int> selectedOptionIndices) {
    final Map<String, int> totals = {
      'palavras_de_afirmacao': 0,
      'tempo_de_qualidade': 0,
      'presentes': 0,
      'atos_de_servico': 0,
      'toque_fisico': 0,
    };

    for (var i = 0; i < selectedOptionIndices.length; i++) {
      if (i >= loveQuestions.length) continue;

      final question = loveQuestions[i];
      final selectedOptionIndex = selectedOptionIndices[i];

      final options = question['options'] as List<dynamic>;

      if (selectedOptionIndex < 0 || selectedOptionIndex >= options.length) {
        continue;
      }

      final scores =
          options[selectedOptionIndex]['scores'] as Map<String, dynamic>;

      scores.forEach((key, value) {
        if (totals.containsKey(key)) {
          totals[key] = totals[key]! + (value as int);
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
    final options = currentQuestion['options'] as List<dynamic>;

    return Scaffold(
      appBar: AppBarComponent(
        'Questão ${index + 1} de ${loveQuestions.length}',
        type: 'back',
      ),
      drawer: DrawerComponent(widget.setPage),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                currentQuestion['question'].toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              ...options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final optionData = entry.value as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(optionIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      optionData['text'].toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
