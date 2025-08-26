import 'package:internet_connection_checker/internet_connection_checker.dart';

class OfflineSync {

  Future<bool> isConnected() async {
    final connectionChecker = InternetConnectionChecker.createInstance();  // Alteração aqui
    return await connectionChecker.hasConnection;  // Use o método correto
  }
}
