
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtDecoder {
  // Função para obter a role a partir do token JWT
  static String getUserRoleFromToken(String token) {
    try {
      final jwt = JWT.decode(token);
      final int idUserType = jwt.payload['idUserType'];

      // Mapeamento das roles com base no idTipoUtilizador
      switch (idUserType) {
        case 1:
          return 'Admin';
        case 2:
          return 'Treinador';
        case 3:
          return 'Olheiro';
        default:
          throw Exception('Tipo de utilizador inválido no token!');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao decodificar o token: $e');
      throw Exception('Erro ao processar o token JWT.');
    }
  }

  // Função para obter o ID do utilizador a partir do token JWT
  static int getUserIdFromToken(String token) {
    try {
      final jwt = JWT.decode(token);
      return jwt.payload['idUser'];
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao decodificar o token: $e');
      return -1;
    }
  }
}
