import 'package:connect/firebase_options.dart';
import 'package:connect/provider/auth_check_screen.dart';
import 'package:connect/provider/auth_provider.dart';
import 'package:connect/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const ConnectUs(),
    ),
  );
}

class ConnectUs extends StatefulWidget {
  const ConnectUs({super.key});

  @override
  State<ConnectUs> createState() => _ConnectUsState();
}

class _ConnectUsState extends State<ConnectUs> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      home: AuthCheckScreen(),
    );
  }
}
