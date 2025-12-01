import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final bool component;
  const Loading({this.component = false, super.key});

  @override
  Widget build(BuildContext context) {
    if (component) {
      return content();
    }

    return Scaffold(body: content());
  }

  Widget content() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", width: 200),
            Text(
              "Carregando...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
