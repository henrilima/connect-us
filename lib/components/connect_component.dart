import 'package:connect/ui/app_color.dart';
import 'package:connect/services/messenger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectComponent extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ConnectComponent({required this.userData, super.key});

  @override
  State<ConnectComponent> createState() => _ConnectComponentState();
}

class _ConnectComponentState extends State<ConnectComponent> {
  @override
  Widget build(BuildContext context) {
    final String relId = widget.userData['relationshipId'];
    final String userId = widget.userData['userId'];
    final String partnerId = widget.userData['partnerId'];

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dados de conexão",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryColorHover,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'ID do relacionamento (compartilhe com seu par e anote este ID - evite perdas):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: relId));
                AppMessenger(
                  context,
                  'Copiado para a área de transferência!',
                  'info',
                ).show();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondaryColorHover.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(relId, style: TextStyle(fontSize: 16)),
                    ),
                    Icon(
                      Icons.copy,
                      size: 16,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Seu ID:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: userId));
                AppMessenger(
                  context,
                  'Copiado para a área de transferência!',
                  'info',
                ).show();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondaryColorHover.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(userId, style: TextStyle(fontSize: 16)),
                    ),
                    Icon(
                      Icons.copy,
                      size: 18,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'ID do seu par:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: partnerId));
                AppMessenger(
                  context,
                  'Copiado para a área de transferência',
                  'info',
                ).show();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondaryColorHover.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(partnerId, style: TextStyle(fontSize: 16)),
                    ),
                    Icon(
                      Icons.copy,
                      size: 18,
                      color: AppColors.textColorSecondary,
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
}
