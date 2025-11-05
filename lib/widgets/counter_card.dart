import 'package:connect/forms/counter_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CounterCard extends StatelessWidget {
  final String text;
  final String value;
  final String description;
  final IconData icon;
  final int type;
  final Function execPlus;
  final Function execMinus;
  final String lastUpdate;
  final bool isCustom;
  final String? counterKey;
  final String? relationshipId;

  const CounterCard({
    required this.icon,
    required this.text,
    required this.value,
    required this.execPlus,
    required this.description,
    required this.execMinus,
    this.isCustom = false,
    this.lastUpdate = '',
    this.relationshipId,
    this.counterKey,
    this.type = 0,
    super.key,
  });

  Color get cardColor {
    if (type == 1) {
      return AppColors.primaryColor;
    } else if (type == 2) {
      return AppColors.secondaryColor;
    }

    return AppColors.cardBackgroundColor;
  }

  Color get textColor {
    if (type == 2) {
      return AppColors.drawerBackgroundColor;
    }

    return AppColors.textColor;
  }

  _editCounter(BuildContext context) {
    if (relationshipId != null && counterKey != null) {
      return Dialoguer.openModalBottomSheet(
        context: context,
        form: CounterForm(relationshipId!, edit: true, counterKey: counterKey),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool confirm = await Dialoguer.showConfirmAlert(
      context: context,
      titleWidget: const Text('Confirmar exclusão'),
      contentWidget: const Text(
        'Tem certeza de que deseja deletar este contador? Esta ação não pode ser desfeita.',
      ),
      actionsWidget: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Deletar contador'),
        ),
      ],
    );

    if (confirm == true && relationshipId != null && counterKey != null) {
      DatabaseService().deleteCounter(relationshipId!, countName: counterKey!);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: cardColor,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 32,
                              height: 1,
                              color: textColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 22,
                              height: 1.5,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      FaIcon(icon, size: 64, color: textColor),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (lastUpdate.isNotEmpty)
                    Text(
                      'Última atualização em: ${DateFormat("dd 'de' MMMM 'às' HH:mm").format(DateTime.parse(lastUpdate))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withAlpha(100),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  SizedBox(height: 16),
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async => await execPlus(),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              AppColors.backgroundColor,
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.plus,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async => execMinus(),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              AppColors.backgroundColor,
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.minus,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isCustom)
              Positioned(
                top: 0,
                right: -6,
                child: PopupMenuButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: AppColors.drawerBackgroundColor,
                  padding: EdgeInsets.all(6),
                  constraints: BoxConstraints(),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.pencil,
                            size: 16,
                            color: AppColors.infoColorHover,
                          ),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.trash,
                            size: 16,
                            color: AppColors.errorColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Excluir',
                            style: TextStyle(color: AppColors.errorColor),
                          ),
                        ],
                      ),
                    ),
                  ],

                  onSelected: (String value) async {
                    if (value == 'edit') {
                      _editCounter(context);
                    } else if (value == 'delete') {
                      await _confirmDelete(context);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
