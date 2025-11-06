import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/loading_screen.dart';
import 'package:connect/widgets/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const ChatScreen(this.setPage, {required this.userData, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Function setPage;
  Map<String, String>? _usernames;

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setPage = widget.setPage;
    _loadUsernames();
  }

  Future<void> _loadUsernames() async {
    final authorUsername = await DatabaseService().getUsername(
      widget.userData['userId'],
    );
    final partnerUsername = await DatabaseService().getUsername(
      widget.userData['partnerId'],
    );

    setState(() {
      _usernames = {'author': authorUsername, 'partner': partnerUsername};
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getMessagesStream(
        widget.userData['relationshipId'],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            _usernames == null) {
          return Loading();
        }

        if (snapshot.hasError) {
          return ErrorScreenComponent("${snapshot.error}");
        }

        final Map<String, dynamic> messages = snapshot.data ?? {};
        Alignment getAlignment(String author) {
          if (author == widget.userData['userId']) {
            return Alignment.centerRight;
          } else {
            return Alignment.centerLeft;
          }
        }

        return Scaffold(
          appBar: AppBarComponent("${_usernames!['partner']}"),
          drawer: DrawerComponent(setPage),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: ListView(
                      reverse: true,
                      children: [
                        ...messages.entries.map((entry) {
                          final el = entry.value;
                          final date = DateTime.parse(el['date']);

                          return MessageComponent(
                            el['message'],
                            DateFormat("dd/MM/y 'às' hh:mm").format(date),
                            alignment: getAlignment(el['author']),
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
                          decoration: InputDecoration(
                            hintText: 'Digite uma mensagem',
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
                          ),
                          onSubmitted: (value) {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryColor,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: AppColors.textColor,
                            size: 20,
                          ),
                          onPressed: () async {
                            if (messageController.text.isEmpty) {
                              return;
                            }

                            try {
                              await DatabaseService().sendMessageInChat(
                                relationshipId:
                                    widget.userData['relationshipId'],
                                author: widget.userData['userId'],
                                message: messageController.text,
                              );
                              messageController.text = "";
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
