import 'dart:io';
import 'package:connect/components/header.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/fade_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:connect/provider/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const SettingsScreen(this.setPage, {required this.userData, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _relationshipData;
  String _message = '';
  bool _isReady = false;
  File? _imageFile;
  bool _isUploading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _getUserAndRelationshipData();
  }

  _initializeData() {
    _userData = widget.userData;
    _relationshipData = widget.userData['relationshipData'];
    _selectedDate = DateTime.parse(_relationshipData!['relationshipDate']);

    _usernameController.text = _userData!['username'];
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _isReady = true;
  }

  _getUserAndRelationshipData() async {
    setState(() => _isReady = false);
    final userData = await DatabaseService().getUserData(
      widget.userData['userId'],
    );
    final relationshipData = await DatabaseService().getRelationshipData(
      userData['relationshipId'],
    );

    if (!mounted) return;

    setState(() {
      _userData = userData;
      _relationshipData = relationshipData;
      _selectedDate = DateTime.parse(relationshipData['relationshipDate']);

      _usernameController.text = userData['username'];
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      _isReady = true;
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  _showMessage({String? message, clear = false}) {
    if (!mounted) return;
    setState(() {
      _message = clear ? '' : message!;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path));

        if (croppedFile != null) {
          setState(() {
            _imageFile = croppedFile;
          });
          _uploadPhoto();
        }
      }
    } catch (e) {
      _showMessage(message: "error:Erro ao selecionar imagem.");
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Editar Foto',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Editar Foto',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  Future<void> _uploadPhoto() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    final success = await ApiService().uploadPhoto(
      _userData!['userId'],
      _imageFile!,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (success) {
      _showMessage(message: "success:Foto de perfil atualizada com sucesso!");
      _getUserAndRelationshipData();
    } else {
      _showMessage(message: "error:Falha ao enviar a foto. Tente novamente.");
    }

    Future.delayed(const Duration(seconds: 4), () {
      _showMessage(clear: true);
    });
  }

  Future<void> _removePhoto() async {
    setState(() {
      _isUploading = true;
    });

    final success = await DatabaseService().updateUser(_userData!['userId'], {
      'photoUrl': null,
    });

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _imageFile = null;
    });

    if (success) {
      _showMessage(message: "success:Foto de perfil removida com sucesso!");
      _getUserAndRelationshipData();
    } else {
      _showMessage(message: "error:Falha ao remover a foto. Tente novamente.");
    }

    Future.delayed(const Duration(seconds: 4), () {
      _showMessage(clear: true);
    });
  }

  updateUserAndRelationshipData() async {
    if (_relationshipData != null) {
      final relationshipDate = DateTime.parse(
        _relationshipData!['relationshipDate'],
      );

      if (_usernameController.text == _userData!['username'] &&
          _selectedDate == relationshipDate) {
        return _showMessage(
          message:
              "warning:Nenhum dado foi alterado, logo, nenhuma modificação precisa ser realizada.",
        );
      }

      if (_usernameController.text.length > 16) {
        return _showMessage(
          message:
              "error:O nome de usuário não pode ter mais que 16 caracteres.",
        );
      }

      DatabaseService().updateUserAndRelationshipData(
        userId: _userData!['userId'],
        relationshipId: _relationshipData!['relationshipId'],
        newUsername: _usernameController.text == _userData!['username']
            ? null
            : _usernameController.text,
        newDate: _selectedDate == relationshipDate ? null : _selectedDate,
      );

      _showMessage(message: "success:Os dados foram atualizados.");
      _getUserAndRelationshipData();

      Future.delayed(const Duration(seconds: 6), () {
        _showMessage(clear: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: "Perfil"),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Configurações de Perfil",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColorHover,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Utilize esta área para ajustar, corrigir ou modificar quaisquer informações que possam ser alteradas.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _isUploading ? null : _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.cardBackgroundColor,
                                child: _isUploading
                                    ? const CircularProgressIndicator()
                                    : ClipOval(
                                        child: _imageFile != null
                                            ? Image.file(
                                                _imageFile!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )
                                            : FadeNetworkImage(
                                                imageUrl:
                                                    _userData!['photoUrl'] ??
                                                    "https://avatar.iran.liara.run/public",
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isUploading ? null : _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((_userData!['photoUrl'] != null &&
                              _userData!['photoUrl'].toString().isNotEmpty) ||
                          _imageFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: _isUploading ? null : _removePhoto,
                              icon: const Icon(
                                FontAwesomeIcons.trash,
                                size: 16,
                                color: AppColors.errorColor,
                              ),
                              label: const Text(
                                "Remover foto",
                                style: TextStyle(color: AppColors.errorColor),
                              ),
                            ),
                          ),
                        ),
                      if (_message.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(height: 24),
                            Text(
                              _message.split(':')[1],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _message.split(':')[0] == 'error'
                                    ? AppColors.errorColor
                                    : _message.split(':')[0] == 'warning'
                                    ? AppColors.warningColor
                                    : _message.split(':')[0] == 'success'
                                    ? AppColors.successColor
                                    : AppColors.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      SizedBox(height: 32),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Nome de usuário',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        readOnly: true,
                        controller: _dateController,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Dia que se conheceram',
                          suffixIcon: IconButton(
                            onPressed: () => _selectDate(context),
                            icon: FaIcon(FontAwesomeIcons.calendar),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isReady
                              ? () => updateUserAndRelationshipData()
                              : null,
                          child: Text("Salvar dados"),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () =>
                              context.read<AuthProvider>().logoutUser(),
                          icon: const Icon(
                            FontAwesomeIcons.rightFromBracket,
                            color: AppColors.errorColor,
                          ),
                          label: const Text(
                            "Sair",
                            style: TextStyle(
                              color: AppColors.errorColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
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
}
