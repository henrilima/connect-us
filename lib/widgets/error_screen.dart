import 'package:flutter/material.dart';

class ErrorScreenComponent extends StatelessWidget {
  final String error;
  const ErrorScreenComponent(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Erro ao carregar dados: $error')));
  }
}
