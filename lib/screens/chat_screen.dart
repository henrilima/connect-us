import 'package:connect/components/header.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/fade_in.dart';
import 'package:connect/widgets/loading_widget.dart';
import 'package:connect/widgets/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connect/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const ChatScreen(this.setPage, {required this.userData, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Function setPage;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _limit = 10;
  Map<String, dynamic> _currentMessages = {};
  String? _editingMessageId;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    setPage = widget.setPage;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _limit += 10;
      });
    }
  }

  Future<void> _handleEditMessage(String messageId, String currentText) async {
    setState(() {
      _editingMessageId = messageId;
      messageController.text = currentText;
    });
    _focusNode.requestFocus();
  }

  Future<void> _handleDeleteMessage(String messageId) async {
    await DatabaseService().deleteMessage(
      relationshipId: widget.userData['relationshipId'],
      messageId: messageId,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "hoje às ${DateFormat('HH:mm').format(date)}";
    } else if (messageDate == yesterday) {
      return "ontem às ${DateFormat('HH:mm').format(date)}";
    } else {
      final day = date.day;
      final month = _getMonthName(date.month);
      final time = DateFormat('HH:mm').format(date);
      return "$day de $month às $time";
    }
  }

  String _getMonthName(int month) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getMessagesStream(
        widget.userData['relationshipId'],
        limit: _limit,
      ),
      initialData: _currentMessages,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _currentMessages.isEmpty) {
          return Loading();
        }

        if (snapshot.hasError) {
          return ErrorScreenComponent("${snapshot.error}");
        }

        if (snapshot.hasData) {
          _currentMessages = snapshot.data ?? {};
        }

        final Map<String, dynamic> messages = _currentMessages;
        Alignment getAlignment(String author) {
          if (author == widget.userData['userId']) {
            return Alignment.centerRight;
          } else {
            return Alignment.centerLeft;
          }
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  setPage,
                  true,
                  title: "${widget.userData['partnerData']['username']}",
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: ListView(
                      controller: _scrollController,
                      reverse: true,
                      children: [
                        ...messages.entries.toList().asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final mapEntry = entry.value;
                          final el = mapEntry.value;
                          final date = DateTime.parse(el['date']);
                          final isMine =
                              el['author'] == widget.userData['userId'];

                          return FadeIn(
                            delay: Duration(milliseconds: index * 50),
                            child: MessageComponent(
                              el['message'],
                              _formatDate(date),
                              messageId: mapEntry.key,
                              alignment: getAlignment(el['author']),
                              isDeleted: el['isDeleted'] ?? false,
                              isMine: isMine,
                              onEdit: (id, text) =>
                                  _handleEditMessage(id, text),
                              onDelete: (id) => _handleDeleteMessage(id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: _editingMessageId != null
                                ? 'Editando mensagem...'
                                : 'Digite uma mensagem',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: _editingMessageId != null
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _editingMessageId = null;
                                        messageController.clear();
                                      });
                                      _focusNode.unfocus();
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (value) {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryColor,
                        child: IconButton(
                          icon: Icon(
                            _editingMessageId != null
                                ? Icons.check
                                : Icons.send,
                            color: AppColors.textColor,
                            size: 20,
                          ),
                          onPressed: () async {
                            final text = messageController.text.trim();
                            if (text.isEmpty) {
                              return;
                            }

                            try {
                              if (_editingMessageId != null) {
                                await DatabaseService().updateMessage(
                                  relationshipId:
                                      widget.userData['relationshipId'],
                                  messageId: _editingMessageId!,
                                  newMessage: text,
                                );
                                setState(() {
                                  _editingMessageId = null;
                                });
                              } else {
                                await DatabaseService().sendMessageInChat(
                                  relationshipId:
                                      widget.userData['relationshipId'],
                                  author: widget.userData['userId'],
                                  message: text,
                                );

                                final partnerId = widget.userData['partnerId'];
                                final token = await DatabaseService()
                                    .getMessagerToken(partnerId);

                                if (token != null) {
                                  final myName =
                                      widget.userData['username'] ?? 'Seu amor';
                                  await ApiService().sendNotification(
                                    token,
                                    "Nova mensagem! 💬",
                                    "$myName: $text",
                                  );
                                }
                              }
                              messageController.clear();
                            } catch (e) {
                              return;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
