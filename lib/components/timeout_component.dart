import 'dart:async';
import 'package:connect/components/partner_status_component.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/utils/dates.dart';
import 'package:flutter/material.dart';

class TimeoutComponent extends StatefulWidget {
  final Map<String, dynamic> infos;

  const TimeoutComponent({super.key, required this.infos});

  @override
  State<TimeoutComponent> createState() => _TimeoutComponentState();
}

class _TimeoutComponentState extends State<TimeoutComponent> {
  Timer? _timer;

  late DateTime userDate;
  Map<String, int>? relationshipDate;

  @override
  void initState() {
    super.initState();
    userDate = DateTime.parse(widget.infos['date']);
    _loadRelationshipData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadRelationshipData() {
    _updateRelationshipDate();

    _timer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _updateRelationshipDate(),
    );
  }

  void _updateRelationshipDate() {
    if (!mounted) return;
    setState(() {
      relationshipDate = getPreciseDifference(
        DateTime(userDate.year, userDate.month, userDate.day),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final years = relationshipDate!['years'] as int;
    final months = relationshipDate!['months'] as int;
    final days = relationshipDate!['days'] as int;
    final hours = relationshipDate!['hours'] as int;
    final minutes = relationshipDate!['minutes'] as int;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 28,
                            color: AppColors.textColor,
                          ),
                          children: [
                            TextSpan(
                              text: widget.infos['author'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ' e ',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                            TextSpan(
                              text: widget.infos['partner'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Vocês se conhecem há',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 36),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          if (years > 0)
                            _buildMinimalCounter(
                              years > 1 ? 'anos' : 'ano',
                              years,
                            ),
                          _buildMinimalCounter(
                            months > 1 ? 'meses' : 'mês',
                            months,
                          ),
                          _buildMinimalCounter(days > 1 ? 'dias' : 'dia', days),
                          if (years <= 0)
                            _buildMinimalCounter(
                              hours > 1 || hours < 1 ? 'horas' : 'hora',
                              hours,
                            ),
                          if (years <= 1)
                            _buildMinimalCounter(
                              minutes > 1 || minutes < 1 ? 'minutos' : 'minuto',
                              minutes,
                            ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.drawerBackgroundColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'São ${getDateInDays(DateTime.parse(widget.infos['date']))} dias de história',
                          style: const TextStyle(
                            color: AppColors.textColorSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.drawerBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PartnerStatusComponent(
                          partnerId: widget.infos['partnerId'],
                          relationshipId: widget.infos['relationshipId'],
                          initialUsername: widget.infos['partner'],
                          initialPhotoUrl: widget.infos['partnerPhotoUrl'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalCounter(String label, int? value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value?.toString() ?? '0',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryColorHover,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textColorSecondary,
          ),
        ),
      ],
    );
  }
}
