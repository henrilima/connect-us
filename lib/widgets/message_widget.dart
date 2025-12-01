import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';

class MessageComponent extends StatelessWidget {
  final String messageId;
  final String text;
  final String date;
  final Alignment alignment;
  final bool isDeleted;
  final bool isMine;
  final Function(String, String) onEdit;
  final Function(String) onDelete;

  const MessageComponent(
    this.text,
    this.date, {
    required this.messageId,
    required this.alignment,
    this.isDeleted = false,
    this.isMine = false,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  BorderRadius getBorderRadius() {
    if (alignment == Alignment.centerLeft) {
      return BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      );
    }
  }

  Color color() {
    if (alignment == Alignment.centerLeft) {
      return AppColors.secondaryColorHover;
    } else {
      return AppColors.primaryColorHover;
    }
  }

  void _showOptions(BuildContext context) {
    if (isDeleted || !isMine) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Ações",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit(messageId, text);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Deletar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(messageId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: () => _showOptions(context),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.all(12.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: color(),
            borderRadius: getBorderRadius(),
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.drawerBackgroundColor,
                    fontWeight: FontWeight.w500,
                    fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    date,
                    style: TextStyle(
                      color: AppColors.backgroundColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
