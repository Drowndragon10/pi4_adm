import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';
import '../autenticacao/jwt_decode.dart';

class EquipasPage extends StatefulWidget {
  const EquipasPage({super.key});

  @override
  State<EquipasPage> createState() => _EquipasPageState();
}

class _EquipasPageState extends State<EquipasPage> {
  Map<String, dynamic>? equipa;
  bool semEquipa = false;
  String? userRole;
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        return;
      }

      // Decodificar o token para obter a role do utilizador
      final role = JwtDecoder.getUserRoleFromToken(token);
      setState(() {
        userRole = role;
      });

      // Carregar as equipas após obter a role
      _fetchEquipas();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _fetchEquipas() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        return;
      }

      userId = JwtDecoder.getUserIdFromToken(token);
      print('DEBUG userId: $userId');

      final url = 'https://pi4-3soq.onrender.com/teams/coach/$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG equipas response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          setState(() {
            equipa = Map<String, dynamic>.from(decoded[0]);
            semEquipa = false;
          });
        } else if ((decoded is List && decoded.isEmpty) ||
            (decoded is Map &&
                (decoded['message'] == 'Team not found.' ||
                    decoded['error'] != null))) {
          setState(() {
            equipa = null;
            semEquipa = true;
          });
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Equipas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
            
          ),
          
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : semEquipa || equipa == null
                    ? const Center(
                        child: Text(
                          'Ainda não tens nenhuma equipa atribuída.',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Card(
                        color: const Color(0xFF2C2C2C),
                        margin: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 18),
                          title: Text(
                            equipa?['name'] ?? 'Sem Nome',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            equipa?['ageCategory']?['name'] ?? 'Sem Categoria',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
          ),
          // Barra Home fixa no fundo
          Container(
            width: double.infinity,
            color: const Color(0xFF303030),
            child: IconButton(
              icon: const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
