import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'autenticacao/auth_service.dart';
import 'autenticacao/jwt_decode.dart';
import 'jogos_page.dart';

class EscalaoPage extends StatefulWidget {
  const EscalaoPage({super.key});

  @override
  State<EscalaoPage> createState() => _EscalaoPageState();
}

class _EscalaoPageState extends State<EscalaoPage> {
  List<dynamic> categorias = [];
  bool isLoadingCategorias = true;
  String? userRole;

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

      _loadCategorias();
      // ignore: empty_catches
    } catch (e) {}
  }

  // Função para buscar as categorias etárias da API
  Future<void> _loadCategorias() async {
    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(
        Uri.parse('https://pi4-3soq.onrender.com/ageCategories'),
        headers: config,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categorias = data;
          isLoadingCategorias = false;
        });
      } else {
        setState(() {
          isLoadingCategorias = false;
        });
        // ignore: avoid_print
        print('Erro ao carregar as categorias: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingCategorias = false;
      });
      // ignore: avoid_print
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Column(
          children: [
            // Título centralizado
            Container(
              color: const Color(0xFF303030),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Jogos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Campo de pesquisa (visual, não funcional)
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lista de escalões ou mensagem de erro
            Expanded(
              child: isLoadingCategorias
                  ? const Center(child: CircularProgressIndicator())
                  : categorias.isEmpty
                      ? const Center(
                          child: Text(
                            'Não existem escalões disponíveis.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: categorias.length,
                          itemBuilder: (context, index) {
                            final categoria = categorias[index]['name'];
                            final idCategoriaEtaria =
                                categorias[index]['idAgeCategory'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Card(
                                color: const Color(0xFF2C2C2C),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  title: Text(
                                    categoria,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JogosPage(
                                          idCategoriaEtaria: idCategoriaEtaria,
                                          categoriaNome: categoria,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Botão home fixo no fundo
            Container(
              color: const Color(0xFF2C2C2C),
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: IconButton(
                icon:
                    const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
