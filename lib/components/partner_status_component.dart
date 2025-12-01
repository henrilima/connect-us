import 'dart:async';
import 'package:connect/services/database_service.dart';
import 'package:connect/services/messenger_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/fade_network_image.dart';
import 'package:connect/ui/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartnerStatusComponent extends StatefulWidget {
  final String partnerId;
  final String relationshipId;
  final String? initialUsername;
  final String? initialPhotoUrl;

  const PartnerStatusComponent({
    super.key,
    required this.partnerId,
    required this.relationshipId,
    this.initialUsername,
    this.initialPhotoUrl,
  });

  @override
  State<PartnerStatusComponent> createState() => _PartnerStatusComponentState();
}

class _PartnerStatusComponentState extends State<PartnerStatusComponent> {
  final DatabaseService _databaseService = DatabaseService();
  late Stream<Map<String, dynamic>> _partnerStream;
  late Stream<Map<String, String>> _lovePingsStream;
  Map<String, String> _lovePingsData = {};
  Timer? _timer;
  bool _isSendingLove = false;
  DateTime? _lastSentDate;

  @override
  void initState() {
    super.initState();
    _partnerStream = _databaseService.getPartnerStream(widget.partnerId);
    _lovePingsStream = _databaseService.getLovePingsStream(
      widget.relationshipId,
    );
    _lovePingsStream.listen((data) {
      if (mounted) {
        setState(() {
          final otherKey = data.keys.firstWhere(
            (k) => k != widget.partnerId,
            orElse: () => '',
          );
          if (otherKey.isNotEmpty) {
            _lastSentDate = DateTime.tryParse(data[otherKey]!);
          }
          _lovePingsData = data;
        });
      }
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendLove() async {
    if (_isSendingLove) return;

    if (_lastSentDate != null) {
      final difference = DateTime.now().difference(_lastSentDate!);
      if (difference.inMinutes < 5) {
        AppMessenger(
          context,
          'Você já enviou amor recentemente. Espere um pouco!',
          'warning',
        ).show();
        return;
      }
    }

    setState(() {
      _isSendingLove = true;
    });

    try {
      final relationshipData = await _databaseService.getRelationshipData(
        widget.relationshipId,
      );
      final authorId = relationshipData['authorId'];
      final partnerId = relationshipData['partnerId'];

      // Determinar quem é o remetente (nós)
      String senderId = '';
      if (authorId == widget.partnerId) {
        senderId = partnerId;
      } else {
        senderId = authorId;
      }

      await _databaseService.sendLove(
        widget.relationshipId,
        senderId,
        widget.partnerId,
      );
    } catch (e) {
      debugPrint('Error sending love: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingLove = false;
        });
      }
    }
  }

  String _formatTimeAgo(String? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.tryParse(timestamp);
    if (date == null) return '';

    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return 'agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} h';
    } else {
      return 'há ${difference.inDays} d';
    }
  }

  String _formatLastLogin(String? lastLogin) {
    if (lastLogin == null || lastLogin == '0') {
      return 'Visto por último: desconhecido';
    }

    final date = DateTime.tryParse(lastLogin);
    if (date == null) return 'Visto por último: desconhecido';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Visto por último: agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Visto por último: há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Visto por último: há ${difference.inHours} h';
    } else {
      return 'Visto por último: ${DateFormat('dd/MM HH:mm').format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _partnerStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              const SkeletonAvatar(radius: 30),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonText(width: 100, height: 16),
                  SizedBox(height: 8),
                  SkeletonText(width: 150, height: 12),
                  SizedBox(height: 8),
                  SkeletonText(width: 80, height: 12),
                ],
              ),
            ],
          );
        }

        final data = snapshot.data ?? {};
        final bool isOnline = data['status'] == true;
        final String lastLogin = data['last-login']?.toString() ?? '0';
        final feeling =
            data['feeling'] ??
            {'label': 'Neutro', 'icon': 0xf11a, 'color': 0xFF9E9E9E};

        final username =
            widget.initialUsername ?? data['username'] ?? 'Parceiro';
        final photoUrl =
            widget.initialPhotoUrl ??
            data['photoUrl'] ??
            "https://avatar.iran.liara.run/public";

        // Precisamos saber nosso ID para saber qual ping é nosso (enviado) e qual é o deles (recebido).
        // Mas não temos nosso ID facilmente.
        // No entanto, sabemos widget.partnerId.
        // Então _lovePingsData[widget.partnerId] é o que ELES enviaram (Recebido por nós).
        // E a outra chave é o que NÓS enviamos.

        String? receivedLoveTime;
        String? sentLoveTime;

        if (_lovePingsData.isNotEmpty) {
          if (_lovePingsData.containsKey(widget.partnerId)) {
            receivedLoveTime = _lovePingsData[widget.partnerId];
          }
          // Encontrar a chave que NÃO é o partnerId
          final otherKey = _lovePingsData.keys.firstWhere(
            (k) => k != widget.partnerId,
            orElse: () => '',
          );
          if (otherKey.isNotEmpty) {
            sentLoveTime = _lovePingsData[otherKey];
          }
        }

        return Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: FadeNetworkImage(
                      imageUrl: photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? AppColors.successColor
                          : AppColors.textColorSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isOnline ? 'Online' : _formatLastLogin(lastLogin),
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        IconData(
                          feeling['icon'],
                          fontFamily: 'FontAwesomeSolid',
                          fontPackage: 'font_awesome_flutter',
                        ),
                        size: 12,
                        color: Color(feeling['color']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feeling['label'],
                        style: TextStyle(
                          color: Color(feeling['color']),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (receivedLoveTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        'Te enviou amor ${_formatTimeAgo(receivedLoveTime)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: _isSendingLove ? null : _sendLove,
                  icon: Icon(
                    _isSendingLove ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.primaryColor,
                  ),
                ),
                if (sentLoveTime != null)
                  Text(
                    _formatTimeAgo(sentLoveTime),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
