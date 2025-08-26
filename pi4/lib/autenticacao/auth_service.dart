import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  // Guardar o token no armazenamento seguro
  Future<bool> saveToken(String authToken) async {
    try {
      await storage.write(key: 'authToken', value: authToken);
      // ignore: avoid_print
      print("Token guardado com sucesso.");

      String? value = await storage.read(key: 'authToken');

      // ignore: avoid_print
      print(value);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao guardar o token: $e');
      return false;
    }
  }

  // Recuperar o token do armazenamento seguro
  Future<String?> getToken() async {
    try {
      String? token = await storage.read(key: 'authToken');
      return token;
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao recuperar o token: $e');
      return null;
    }
  }

  // Apagar o token do armazenamento seguro (logout)
  Future<bool> deleteToken() async {
    try {
      await storage.delete(key: 'authToken');
      // ignore: avoid_print
      print("Token apagado com sucesso.");
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao apagar o token: $e');
      return false;
    }
  }
}
