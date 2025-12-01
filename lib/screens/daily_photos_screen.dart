import 'dart:io';
import 'package:connect/components/header.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/services/messenger_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/fade_network_image.dart';
import 'package:connect/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';

class DailyPhotosScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;

  const DailyPhotosScreen(this.setPage, {super.key, required this.userData});

  @override
  State<DailyPhotosScreen> createState() => _DailyPhotosScreenState();
}

class _DailyPhotosScreenState extends State<DailyPhotosScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ApiService _apiService = ApiService();
  late Stream<Map<String, dynamic>> _photosStream;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _photosStream = _databaseService.getDailyPhotosStream(
      widget.userData['relationshipId'],
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar Foto',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Ajustar Foto'),
      ],
    );

    if (croppedFile == null) return;

    if (!mounted) return;

    // Pedir legenda
    String caption = '';
    final captionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Legenda'),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(hintText: 'Digite uma legenda...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Pular'),
          ),
          TextButton(
            onPressed: () {
              caption = captionController.text;
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    setState(() {
      _isUploading = true;
    });

    final success = await _apiService.uploadDailyPhoto(
      widget.userData['relationshipId'],
      widget.userData['userId'],
      File(croppedFile.path),
    );

    if (success) {
      await _databaseService.updateDailyPhotoData(
        widget.userData['relationshipId'],
        widget.userData['userId'],
        caption: caption.isNotEmpty ? caption : null,
        partnerId: widget.userData['partnerId'],
      );

      if (mounted) {
        AppMessenger(context, 'Foto enviada com sucesso!', 'success').show();
      }
    } else {
      if (mounted) {
        AppMessenger(context, 'Erro ao enviar foto.', 'error').show();
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _editCaption(String? currentCaption) async {
    final captionController = TextEditingController(text: currentCaption);
    String? newCaption;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Legenda'),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(
            hintText: 'Digite a nova legenda...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              newCaption = captionController.text;
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newCaption == null) return;

    try {
      await _databaseService.updateDailyPhotoData(
        widget.userData['relationshipId'],
        widget.userData['userId'],
        caption: newCaption!.isNotEmpty ? newCaption : null,
      );
      if (mounted) {
        AppMessenger(context, 'Legenda atualizada!', 'success').show();
      }
    } catch (e) {
      if (mounted) {
        AppMessenger(context, 'Erro ao atualizar legenda: $e', 'error').show();
      }
    }
  }

  void _showEditOptions(String? currentCaption) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_rounded,
                color: Colors.white,
              ),
              title: const Text(
                'Alterar Foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded, color: Colors.white),
              title: const Text(
                'Editar Legenda',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _editCaption(currentCaption);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _expandPhoto(String photoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: FadeNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPhoto(String url) async {
    try {
      // Baixar o arquivo primeiro
      final String fileName = url.split('/').last;
      final String path = '${Directory.systemTemp.path}/$fileName';
      await _apiService.downloadFile(url, path);

      await Gal.putImage(path);
      if (mounted) {
        AppMessenger(context, 'Foto salva na galeria!', 'success').show();
      }
    } catch (e) {
      if (mounted) {
        AppMessenger(context, 'Erro ao salvar foto: $e', 'error').show();
      }
    }
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Foto'),
        content: const Text('Tem certeza que deseja excluir sua foto do dia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _databaseService.deleteDailyPhoto(
        widget.userData['relationshipId'],
        widget.userData['userId'],
      );
      if (mounted) {
        AppMessenger(context, 'Foto excluída com sucesso!', 'success').show();
      }
    } catch (e) {
      if (mounted) {
        AppMessenger(context, 'Erro ao excluir foto: $e', 'error').show();
      }
    }
  }

  Widget _buildPhotoCard(
    String title,
    Map<String, dynamic>? photoData,
    bool isMe,
  ) {
    if (photoData == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryColorHover.withAlpha(25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColorHover.withAlpha(50),
                  width: 2,
                ),
              ),
              child: Icon(
                isMe ? FontAwesomeIcons.camera : FontAwesomeIcons.image,
                size: 40,
                color: AppColors.primaryColorHover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isMe ? 'Envie seu registro único' : 'Aguardando registro do par',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isMe) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadPhoto,
                icon: const Icon(Icons.upload_rounded, size: 24),
                label: const Text(
                  'Enviar Foto',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColorHover,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryColorHover.withAlpha(100),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _expandPhoto(photoData['photoUrl']),
              child: FadeNetworkImage(
                imageUrl: photoData['photoUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(50),
                      Colors.black.withAlpha(225),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColorHover,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (photoData['timestamp'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(DateTime.parse(photoData['timestamp'])),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (photoData['caption'] != null &&
                      photoData['caption'].toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      photoData['caption'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (!isMe)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _downloadPhoto(photoData['photoUrl']),
                        icon: const Icon(Icons.download_rounded),
                        color: Colors.white,
                        tooltip: 'Baixar foto',
                      ),
                      IconButton(
                        onPressed: () => _expandPhoto(photoData['photoUrl']),
                        icon: const Icon(Icons.fullscreen_rounded),
                        color: Colors.white,
                        tooltip: 'Expandir',
                      ),
                    ],
                  ),
                ),
              ),
            if (isMe)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _downloadPhoto(photoData['photoUrl']),
                        icon: const Icon(Icons.download_rounded),
                        color: Colors.white,
                        tooltip: 'Baixar foto',
                      ),
                      IconButton(
                        onPressed: _isUploading
                            ? null
                            : () => _showEditOptions(photoData['caption']),
                        icon: const Icon(Icons.edit_rounded),
                        color: Colors.white,
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        onPressed: _isUploading ? null : _deletePhoto,
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Excluir foto',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              widget.setPage,
              true,
              title: 'Registro Único',
              photoUrl: widget.userData['photoUrl'],
            ),
            Expanded(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: _photosStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loading(component: true);
                  }

                  final photos = snapshot.data ?? {};
                  final myId = widget.userData['userId'];
                  final partnerId = widget.userData['partnerId'];

                  final myPhoto = photos[myId] != null
                      ? Map<String, dynamic>.from(photos[myId] as Map)
                      : null;
                  final partnerPhoto = photos[partnerId] != null
                      ? Map<String, dynamic>.from(photos[partnerId] as Map)
                      : null;

                  return PageView(
                    padEnds: false,
                    controller: PageController(viewportFraction: 0.90),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPhotoCard('Registro do Par', partnerPhoto, false),
                      _buildPhotoCard('Seu Registro', myPhoto, true),
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
}
