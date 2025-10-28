import 'package:flutter/foundation.dart';
import 'package:connect/utils/storage.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;
  bool get isAuthenticated => _userId != null && _userId!.isNotEmpty;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  Future<void> initializeUser() async {
    _userId = await Storage().getId();
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> loginUser(String id) async {
    await Storage().saveId(id);
    _userId = id;
    notifyListeners();
  }

  Future<void> logoutUser() async {
    await Storage().deleteId();
    _userId = null;
    notifyListeners();
  }
}
