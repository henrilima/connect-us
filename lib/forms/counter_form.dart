import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: AppColors.backgroundColor,
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.edit ? 'Editar' : 'Adicionar'} Contador',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColorHover,
                ),
              ),
              Text(
                widget.edit
                    ? "Edite seu contador. Você pode alterar todas as informações dele."
                    : "Adicione um contador personalizado na sua lista de contadores e comece a registrar algo novo.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              if (_message.isNotEmpty) SizedBox(height: 12),
              if (_message.isNotEmpty)
                Text(
                  _message.split(':')[1],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _message.split(':')[0] == 'error'
                        ? AppColors.errorColor
                        : AppColors.successColor,
                  ),
                ),
              SizedBox(height: 32),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'O que será contado?',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Descrição do contador',
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Ícone',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryColorHover,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
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
                              ),
                              SizedBox(height: 22),
                              Container(
                                height: 258,
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8,
                                  ),
                                  border: BoxBorder.all(
                                    color: AppColors.drawerBackgroundColor,
                                    width: 1,
                                  ),
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
                    icon: FaIcon(IconHelper.getIcon(_iconName), size: 28),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty ||
                        _descriptionController.text.isEmpty) {
                      _showMessage(
                        message:
                            "error:Os campos não podem estar vazios, insira todos os dados corretamente.",
                      );
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
                  ),
                ),
              ),
            ],
          ),
        ),
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
          icon: FaIcon(entry.value, color: Colors.white),
          onPressed: () => onSelected(entry.key),
        );
      },
    );
  }
}
