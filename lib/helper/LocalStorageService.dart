import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late LocalStorageService _instance;
  static late SharedPreferences _preferences;
  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance;
  }

  static onLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.clear();
  }

  static final String authorizationToken = "Authorization";
  static final String XGoogAuthUser = "X-Goog-AuthUser";


  /// ----------------------------------------------------------
  /// Method that saves the user language code
  /// ----------------------------------------------------------
  static Future<bool> setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(authorizationToken, value);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(authorizationToken);
  }

  static Future<bool> setXGoodAuthUser(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(XGoogAuthUser, value);
  }

  static Future<String?> getXGoodAuthUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(XGoogAuthUser);
  }


}
