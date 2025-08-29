import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';
import '../autenticacao/jwt_decode.dart';

class RelatoriosSubmetidosPage extends StatefulWidget {
  const RelatoriosSubmetidosPage({super.key});

  @override
  State<RelatoriosSubmetidosPage> createState() =>
      _RelatoriosSubmetidosPageState();
}

class _RelatoriosSubmetidosPageState extends State<RelatoriosSubmetidosPage> {
  List<dynamic> relatorios = [];
  bool isLoading = true;
  String? userRole;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadRelatoriosOlheiro();
  }

  // Função para buscar relatórios submetidos do olheiro logado
  Future<void> _loadRelatoriosOlheiro() async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      if (mounted) {
        _redirectToLogin();
      }
      return;
    }

    try {
      // Extrair informações do token
      final role = JwtDecoder.getUserRoleFromToken(token);
      final id = JwtDecoder.getUserIdFromToken(token);

      if (mounted) {
        setState(() {
          userRole = role;
          userId = id;
        });
      }

      // Verificar se o utilizador é do tipo Olheiro
      if (role != 'Olheiro') {
        return;
      }

      // Fazer a chamada para obter os relatórios do utilizador
      final response = await http.get(
        Uri.parse(
            'https://pi4-backend-r17y.onrender.com/relatorios/utilizador/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            relatorios = json.decode(response.body); // Carregar os relatórios
          });
        }
      } else {}
      // ignore: empty_catches
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Atualizar o estado de carregamento
        });
      }
    }
  }

  // Função para redirecionar ao login
  void _redirectToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Retorna a cor do cartão com base no estado do relatório
  Color _getCardBorderColor(String estado) {
    if (estado == "Aprovado") {
      return Colors.green;
    } else if (estado == "Reprovado") {
      return Colors.red;
    } else {
      return Colors.transparent; // Branco para "Em Revisão"
    } // Retorno padrão caso o estado não seja conhecido
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : relatorios.isEmpty
              ? const Center(
                  child: Text(
                    'Sem relatórios disponíveis.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: relatorios.length,
                  itemBuilder: (context, index) {
                    final relatorio = relatorios[index];
                    final String estado = relatorio['estado'] ?? "N/A";

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212), // Cor do fundo
                        borderRadius:
                            BorderRadius.circular(16), // Bordas arredondadas
                        border: Border.all(
                          color: _getCardBorderColor(estado), // Cor da outline
                          width: estado == "Em Revisão"
                              ? 0
                              : 2, // Apenas aprovado/rejeitado tem contorno
                        ),
                      ),
                      height: 140, // Altura fixa do card
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3, // Parte do texto
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Nome do atleta no topo
                                  Text(
                                    relatorio['atleta']?['nome'] ?? 'Sem Nome',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Estado do atleta no final
                                  Text(
                                    estado,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2, // Parte da imagem
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Image.asset(
                                  'assets/images/silhueta.png',
                                  fit: BoxFit.contain,
                                  height: 120,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
