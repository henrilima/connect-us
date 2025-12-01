import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/utils/icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CounterForm extends StatefulWidget {
  final String relationshipId;
  final String? counterKey;
  final bool edit;

  const CounterForm(
    this.relationshipId, {
    this.edit = false,
    this.counterKey,
    super.key,
  });

  @override
  State<CounterForm> createState() => _CounterFormState();
}

class _CounterFormState extends State<CounterForm> {
  String _message = '';
  String _iconName = 'nodes';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  _showMessage({String? message, clear = false}) {
    setState(() {
      _message = clear ? '' : message!;
    });
  }

  _setIcon(String icon) {
    Navigator.of(context).pop();
    setState(() {
      _iconName = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    _tryGetCounterData();
  }

  _tryGetCounterData() async {
    if (widget.edit) {
      final data = await DatabaseService().getCustomCounter(
        widget.relationshipId,
        widget.counterKey as String,
      );

      _titleController.text = data['title'];
      _descriptionController.text = data['description'];
      setState(() {
        _iconName = data['icon'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.edit ? 'Editar' : 'Adicionar'} Contador',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.edit
                ? "Edite seu contador. Você pode alterar todas as informações dele."
                : "Adicione um contador personalizado na sua lista de contadores e comece a registrar algo novo.",
            style: TextStyle(fontSize: 14, color: AppColors.textColorSecondary),
          ),
          const SizedBox(height: 12),
          if (_message.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _message.split(':')[0] == 'error'
                    ? AppColors.errorColor.withAlpha(26)
                    : AppColors.successColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _message.split(':')[0] == 'error'
                      ? AppColors.errorColor.withAlpha(128)
                      : AppColors.successColor.withAlpha(128),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _message.split(':')[0] == 'error'
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: _message.split(':')[0] == 'error'
                        ? AppColors.errorColor
                        : AppColors.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _message.split(':')[1],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _message.split(':')[0] == 'error'
                            ? AppColors.errorColor
                            : AppColors.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textColor),
            decoration: InputDecoration(
              hintText: 'O que será contado?',
              filled: true,
              fillColor: AppColors.drawerBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: AppColors.textColor),
            decoration: InputDecoration(
              hintText: 'Descrição do contador',
              filled: true,
              fillColor: AppColors.drawerBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async {
              await Dialoguer.showConfirmAlert(
                context: context,
                titleWidget: Text(
                  "Selecione o ícone",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primaryColorHover,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                contentWidget: SizedBox(
                  height: 320,
                  child: Column(
                    children: [
                      Text(
                        'Você pode dar scroll e selecionar um dos diversos ícones disponíveis',
                        style: TextStyle(color: AppColors.textColorSecondary),
                      ),
                      SizedBox(height: 22),
                      Container(
                        height: 258,
                        width: 300,
                        decoration: BoxDecoration(
                          color: AppColors.drawerBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          child: IconPicker(onSelected: _setIcon),
                        ),
                      ),
                    ],
                  ),
                ),
                actionsWidget: [],
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.drawerBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    'Ícone',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  FaIcon(
                    IconHelper.getIcon(_iconName),
                    size: 24,
                    color: AppColors.primaryColorHover,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColorHover,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _descriptionController.text.isEmpty) {
                  _showMessage(
                    message:
                        "error:Os campos não podem estar vazios, insira todos os dados corretamente.",
                  );
                  return;
                }

                _showMessage(clear: true);

                await DatabaseService().setCounter(
                  widget.relationshipId,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  icon: _iconName,
                  update: widget.edit,
                  counterKey: widget.counterKey,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(
                "${widget.edit ? 'Editar' : 'Adicionar'} Contador",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconPicker extends StatelessWidget {
  final Function(String iconName) onSelected;
  const IconPicker({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final entries = IconHelper.icons.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return IconButton(
          iconSize: 30,
          icon: FaIcon(entry.value, color: AppColors.textColor),
          onPressed: () => onSelected(entry.key),
        );
      },
    );
  }
}
