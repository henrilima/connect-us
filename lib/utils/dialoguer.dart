import 'package:flutter/material.dart';

/// Classe Dialoguer, feita para exibir diálogos simples ou customizados e modais.
class Dialoguer {
  static void showSimpleAlert({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void showCustomAlert({
    required BuildContext context,
    required Widget titleWidget,
    required Widget contentWidget,
    String buttonText = 'OK',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: titleWidget,
          content: contentWidget,
          actions: [
            TextButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showConfirmAlert({
    required BuildContext context,
    required Widget titleWidget,
    required Widget contentWidget,
    required List<Widget> actionsWidget,
    String buttonText = 'OK',
  }) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: titleWidget,
          content: contentWidget,
          actions: actionsWidget,
        );
      },
    );
    if (confirm == null) return false;
    return confirm;
  }

  static void openModalBottomSheet({
    required BuildContext context,
    required Widget form,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: form,
            ),
          ),
        );
      },
    );
  }
}
