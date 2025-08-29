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
  String? filtroEstado;

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
            'https://pi4-3soq.onrender.com/reports/user/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            relatorios = json.decode(response.body); // Carregar os relatórios
          });
        }
      }
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

  // Filtro local por estado
  List<dynamic> get filteredRelatorios {
    if (filtroEstado == null || filtroEstado == 'Todos') return relatorios;
    return relatorios.where((r) => r['status'] == filtroEstado).toList();
  }

  // Cores para o estado
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case "Aprovado":
        return Colors.green;
      case "Reprovado":
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case "Aprovado":
        return "Aprovado";
      case "Reprovado":
        return "Reprovado";
      default:
        return "Pendente";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Relatórios',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: Column(
        children: [
          // Botão Filtros
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: _showFiltroEstadoDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text(
                  'Filtros',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // Lista de relatórios
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : filteredRelatorios.isEmpty
                    ? const Center(
                        child: Text(
                          'Sem relatórios disponíveis.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRelatorios.length,
                        itemBuilder: (context, index) {
                          final relatorio = filteredRelatorios[index];
                          final String estado = relatorio['status'] ?? "N/A";
                          final DateTime? data = relatorio['reportDate'] != null
                              ? DateTime.tryParse(relatorio['reportDate'])
                              : null;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Relatório - ${data != null ? "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}" : "Sem data"}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _getEstadoLabel(estado),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: _getEstadoColor(estado),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // podes adicionar onTap se quiseres detalhes
                            ),
                          );
                        },
                      ),
          ),
          // Barra Home fixa no fundo
          Container(
            width: double.infinity,
            color: const Color(0xFF303030),
            child: IconButton(
              icon: const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
              onPressed: () {
                Navigator.pop(context); // Ou navega para DashboardPage
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltroEstadoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Estado',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FiltroEstadoButton(
                  label: 'Pendente',
                  onTap: () {
                    setState(() => filtroEstado = 'Pendente');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _FiltroEstadoButton(
                  label: 'Aprovado',
                  onTap: () {
                    setState(() => filtroEstado = 'Aprovado');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _FiltroEstadoButton(
                  label: 'Reprovado',
                  onTap: () {
                    setState(() => filtroEstado = 'Reprovado');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _FiltroEstadoButton(
                  label: 'Limpar filtro',
                  onTap: () {
                    setState(() => filtroEstado = null);
                    Navigator.of(context).pop();
                  },
                  isClear: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Botão customizado para o filtro
class _FiltroEstadoButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isClear;

  const _FiltroEstadoButton({
    required this.label,
    required this.onTap,
    this.isClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isClear ? Colors.white : Colors.black,
          foregroundColor: isClear ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}