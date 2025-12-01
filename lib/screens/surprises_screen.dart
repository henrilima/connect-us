import 'package:connect/components/header.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:connect/forms/surprise_form.dart';
import 'package:connect/widgets/fade_in.dart';

class SurprisesScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;

  const SurprisesScreen(this.setPage, {super.key, required this.userData});

  @override
  State<SurprisesScreen> createState() => _SurprisesScreenState();
}

class _SurprisesScreenState extends State<SurprisesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _surprises = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startListening();
  }

  void _startListening() {
    DatabaseService()
        .getSurprisesStream(widget.userData['relationshipId'])
        .listen((data) {
          if (mounted) {
            setState(() {
              _surprises = data;
            });
          }
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getSurprises(bool received) {
    final userId = widget.userData['userId'];
    final list = _surprises.values
        .map((e) => Map<String, dynamic>.from(e))
        .where((s) {
          if (received) {
            return s['receiverUid'] == userId;
          } else {
            return s['senderUid'] == userId;
          }
        })
        .toList();

    list.sort((a, b) {
      final dateA = DateTime.parse(a['scheduledFor']);
      final dateB = DateTime.parse(b['scheduledFor']);
      return dateB.compareTo(dateA);
    });

    return list;
  }

  void _showSurpriseContent(Map<String, dynamic> surprise) {
    final isLocked = DateTime.now().isBefore(
      DateTime.parse(surprise['scheduledFor']),
    );

    if (isLocked) return;

    if (surprise['receiverUid'] == widget.userData['userId'] &&
        !(surprise['isRead'] ?? false)) {
      DatabaseService().markSurpriseAsRead(
        widget.userData['relationshipId'],
        surprise['id'],
      );
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.gift,
                size: 48,
                color: AppColors.primaryColorHover,
              ),
              const SizedBox(height: 24),
              Text(
                surprise['title'] ?? 'Surpresa!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                surprise['message'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Agendado para: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(surprise['scheduledFor']))}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColorHover,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSurpriseForm({Map<String, dynamic>? surprise}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SurpriseForm(
        userData: widget.userData,
        surprise: surprise,
        onSuccess: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editSurprise(Map<String, dynamic> surprise) {
    _openSurpriseForm(surprise: surprise);
  }

  void _deleteSurprise(String surpriseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.drawerBackgroundColor,
        title: Text(
          'Excluir Surpresa',
          style: TextStyle(color: AppColors.textColor),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta surpresa?',
          style: TextStyle(color: AppColors.textColorSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              DatabaseService().deleteSurprise(
                widget.userData['relationshipId'],
                surpriseId,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: AppColors.errorColorHover),
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
        onPressed: () => _openSurpriseForm(),
        backgroundColor: AppColors.primaryColorHover,
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: 'Surpresas'),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryColorHover,
              labelColor: AppColors.primaryColorHover,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Recebidas'),
                Tab(text: 'Enviadas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildList(true), _buildList(false)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool received) {
    final list = _getSurprises(received);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.boxOpen,
              size: 48,
              color: Colors.grey.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              received
                  ? 'Nenhuma surpresa recebida ainda.'
                  : 'Você ainda não enviou nenhuma surpresa.',
              style: TextStyle(
                color: AppColors.textColorSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final surprise = list[index];
        final scheduledDate = DateTime.parse(surprise['scheduledFor']);
        final now = DateTime.now();
        final isLocked = now.isBefore(scheduledDate);
        final isRead = surprise['isRead'] ?? false;

        return FadeIn(
          delay: Duration(milliseconds: index * 100),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.drawerBackgroundColor,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.withAlpha(26)
                      : (isRead
                            ? AppColors.primaryColorHover.withAlpha(26)
                            : AppColors.primaryColorHover.withAlpha(51)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked ? FontAwesomeIcons.lock : FontAwesomeIcons.gift,
                  color: isLocked ? Colors.grey : AppColors.primaryColorHover,
                ),
              ),
              title: Text(
                isLocked
                    ? (surprise['title'] != null && surprise['title'].isNotEmpty
                          ? surprise['title']
                          : 'Surpresa Bloqueada')
                    : (surprise['title'] != null && surprise['title'].isNotEmpty
                          ? surprise['title']
                          : 'Surpresa!'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    isLocked
                        ? 'Disponível em: ${DateFormat('dd/MM/yyyy HH:mm').format(scheduledDate)}'
                        : (received
                              ? 'Toque para abrir'
                              : 'Agendada para: ${DateFormat('dd/MM/yyyy HH:mm').format(scheduledDate)}'),
                    style: TextStyle(
                      color: AppColors.textColorSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: received
                  ? (isLocked
                        ? null
                        : (!isRead
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.errorColorHover,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null))
                  : PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textColorSecondary,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editSurprise(surprise);
                        } else if (value == 'delete') {
                          _deleteSurprise(surprise['id']);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text(
                                'Excluir',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                    ),
              onTap: () => _showSurpriseContent(surprise),
            ),
          ),
        );
      },
    );
  }
}
