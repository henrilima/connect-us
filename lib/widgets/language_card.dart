import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';

class LoveLanguageInfoCard extends StatelessWidget {
  final String title;
  final Color color;
  final String whatIs;
  final String howToShow;
  final String practicalExamples;
  final String needWhenStressed;
  final String toAvoid;

  const LoveLanguageInfoCard({
    super.key,
    required this.title,
    required this.color,
    required this.whatIs,
    required this.howToShow,
    required this.practicalExamples,
    required this.needWhenStressed,
    required this.toAvoid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Divider(color: color),
            SizedBox(height: 12),
            _buildInfoRow('O que é:', whatIs),
            const SizedBox(height: 12),
            _buildInfoRow('Como demonstrar:', howToShow),
            const SizedBox(height: 12),
            _buildInfoRow('Exemplos Práticos:', practicalExamples),
            const SizedBox(height: 12),
            _buildInfoRow('Precisa quando estressado:', needWhenStressed),
            const SizedBox(height: 12),
            _buildInfoRow(
              'A Evitar:',
              toAvoid,
              color: AppColors.errorColorHover,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String content, {
    Color color = AppColors.textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textColorSecondary,
          ),
        ),
      ],
    );
  }
}
