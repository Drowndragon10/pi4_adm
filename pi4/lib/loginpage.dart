import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi4/termosecondicoes.dart';
import 'dart:convert';
import 'autenticacao/auth_service.dart';
import 'autenticacao/jwt_decode.dart'; // Importa o seu arquivo de jwt_decode
import 'autenticacao/verificarwifi.dart';

import 'main.dart';
import 'olheiro/olheiro.dart';
import 'treinador/treinador.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Verificar se há conexão com a internet
  Future<bool> _checkConnection() async {
    final offlineSync = OfflineSync();
    return await offlineSync.isConnected();
  }

  // Mostrar pop-up quando não há conexão
  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262626), // Cor de fundo
          title: const Text(
            'Sem Conexão',
            style: TextStyle(color: Colors.white), // Cor do texto do título
          ),
          content: const Text(
            'Não há conexão com a internet. Por favor, verifique a sua conexão.',
            style: TextStyle(color: Colors.white70), // Cor do texto do conteúdo
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Cor dourada
                foregroundColor: Colors.black, // Cor do texto no botão
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Borda arredondada
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar pop-up de erro de tipo de utilizador
  void _showUserRoleErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro de Acesso'),
          content: const Text(
              'Tipo de utilizador inválido. Contacte o administrador.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    bool isConnected = await _checkConnection();
    if (!isConnected) {
      _showNoConnectionDialog();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://pi4-3soq.onrender.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String authToken = data['authToken'];

        // Guardar o token usando AuthService
        final authService = AuthService();
        bool isTokenSaved = await authService.saveToken(authToken);

        if (isTokenSaved) {
          try {
            final userRole = JwtDecoder.getUserRoleFromToken(authToken);

            _navigateBasedOnRole(userRole);
          } catch (e) {
            _showUserRoleErrorDialog();
          }
        } else {}
      } else {}
    } catch (e) {
      // ignore: avoid_print
      print('Erro na requisição: $e');
    }
  }

  // Navegar com base na role do utilizador
  void _navigateBasedOnRole(String role) {
    if (role == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (role == 'Olheiro') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OlheiroPage()),
      );
    } else if (role == 'Treinador') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Treinador()),
      );
    } else {
      _showUserRoleErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/images/image.png', // Caminho do teu logo
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF444444),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Palavra-passe',
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF444444),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TermosPage()),
                      );
                    },
                    child: const Text(
                      'Termos de utilização e\nPolítica de privacidade',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
