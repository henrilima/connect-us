import 'package:connect/components/header.dart';
import 'package:connect/forms/moment_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/widgets/fade_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MomentsScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;

  const MomentsScreen(this.setPage, {super.key, required this.userData});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  void _openMomentForm([Map<String, dynamic>? moment]) {
    Dialoguer.openModalBottomSheet(
      context: context,
      form: MomentForm(userData: widget.userData, moment: moment),
    );
  }

  void _confirmDelete(String momentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Excluir Momento',
          style: TextStyle(color: AppColors.textColor),
        ),
        content: Text(
          'Tem certeza que deseja excluir este momento?',
          style: TextStyle(color: AppColors.textColorSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              DatabaseService().deleteMoment(
                widget.userData['relationshipId'],
                momentId,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openMomentForm(),
        backgroundColor: AppColors.primaryColorHover,
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: 'Momentos'),
            Expanded(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: DatabaseService().getMomentsStream(
                  widget.userData['relationshipId'],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final moments = snapshot.data ?? {};
                  final pendingMoments = <Map<String, dynamic>>[];
                  final completedMoments = <Map<String, dynamic>>[];

                  moments.forEach((key, value) {
                    final moment = Map<String, dynamic>.from(value);
                    moment['id'] = key;
                    if (moment['isCompleted'] == true) {
                      completedMoments.add(moment);
                    } else {
                      pendingMoments.add(moment);
                    }
                  });

                  pendingMoments.sort((a, b) {
                    final dateA = a['scheduledDate'] ?? a['createdAt'] ?? '';
                    final dateB = b['scheduledDate'] ?? b['createdAt'] ?? '';
                    return dateA.compareTo(dateB);
                  });

                  completedMoments.sort((a, b) {
                    final dateA = b['completedAt'] ?? '';
                    final dateB = a['completedAt'] ?? '';
                    return dateA.compareTo(dateB);
                  });

                  if (pendingMoments.isEmpty && completedMoments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.listCheck,
                            size: 64,
                            color: AppColors.textColorSecondary.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum momento registrado.\nQue tal planejar algo juntos?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textColorSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (pendingMoments.isNotEmpty) ...[
                        Text(
                          'Para fazer',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...pendingMoments.asMap().entries.map(
                          (entry) => FadeIn(
                            delay: Duration(milliseconds: entry.key * 100),
                            child: _buildMomentCard(entry.value),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (completedMoments.isNotEmpty) ...[
                        Text(
                          'Concluídos',
                          style: TextStyle(
                            color: AppColors.textColorSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...completedMoments.asMap().entries.map(
                          (entry) => FadeIn(
                            delay: Duration(milliseconds: entry.key * 100),
                            child: _buildMomentCard(
                              entry.value,
                              isCompleted: true,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentCard(
    Map<String, dynamic> moment, {
    bool isCompleted = false,
  }) {
    final scheduledDate = moment['scheduledDate'] != null
        ? DateTime.parse(moment['scheduledDate'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.drawerBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? AppColors.successColor.withAlpha(51)
              : AppColors.primaryColor.withAlpha(51),
          child: Icon(
            isCompleted ? FontAwesomeIcons.check : FontAwesomeIcons.clock,
            color: isCompleted
                ? AppColors.successColor
                : AppColors.primaryColor,
            size: 18,
          ),
        ),
        title: Text(
          moment['title'],
          style: TextStyle(
            color: isCompleted
                ? AppColors.textColorSecondary
                : AppColors.textColor,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moment['description'] != null &&
                moment['description'].isNotEmpty)
              Text(
                moment['description'],
                style: TextStyle(color: AppColors.textColorSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (scheduledDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.calendarDay,
                    size: 12,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM HH:mm').format(scheduledDate),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: !isCompleted
            ? PopupMenuButton<String>(
                icon: Icon(
                  FontAwesomeIcons.ellipsisVertical,
                  color: AppColors.textColorSecondary,
                  size: 18,
                ),
                color: AppColors.backgroundColor,
                onSelected: (value) {
                  if (value == 'complete') {
                    DatabaseService().markMomentAsCompleted(
                      widget.userData['relationshipId'],
                      moment['id'],
                    );
                  } else if (value == 'edit') {
                    _openMomentForm(moment);
                  } else if (value == 'delete') {
                    _confirmDelete(moment['id']);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.check,
                          size: 16,
                          color: AppColors.successColor,
                        ),
                        const SizedBox(width: 8),
                        Text('Concluir'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.pen,
                          size: 16,
                          color: AppColors.textColor,
                        ),
                        const SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.trash,
                          size: 16,
                          color: AppColors.errorColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Excluir',
                          style: TextStyle(color: AppColors.errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : IconButton(
                icon: Icon(
                  FontAwesomeIcons.trash,
                  size: 18,
                  color: AppColors.textColorSecondary,
                ),
                onPressed: () => _confirmDelete(moment['id']),
              ),
      ),
    );
  }
}
