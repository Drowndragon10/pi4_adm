import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:http/http.dart' as http; // Importa o pacote http para requisições HTTP
import 'dart:convert'; // Importa para codificação/decodificação JSON
import '../autenticacao/auth_service.dart'; // Serviço de autenticação
import '../autenticacao/jwt_decode.dart'; // Utilitário para decodificar JWT

// Página de relatórios submetidos pelo olheiro
class RelatoriosSubmetidosPage extends StatefulWidget {
  const RelatoriosSubmetidosPage({super.key});

  @override
  State<RelatoriosSubmetidosPage> createState() =>
      _RelatoriosSubmetidosPageState();
}

// Estado da página de relatórios submetidos
class _RelatoriosSubmetidosPageState extends State<RelatoriosSubmetidosPage> {
  List<dynamic> relatorios = []; // Lista de relatórios carregados
  bool isLoading = true; // Indica se está carregando dados
  String? userRole; // Papel do utilizador
  int? userId; // ID do utilizador autenticado
  String? filtroEstado; // Filtro de estado selecionado

  @override
  void initState() {
    super.initState();
    _loadRelatoriosOlheiro(); // Carrega relatórios ao iniciar
  }

  // Função para buscar relatórios submetidos do olheiro logado
  Future<void> _loadRelatoriosOlheiro() async {
    final authService = AuthService(); // Instancia o serviço de autenticação
    final token = await authService.getToken(); // Obtém o token

    if (token == null) {
      if (mounted) {
        _redirectToLogin(); // Redireciona se não houver token
      }
      return;
    }

    try {
      // Extrair informações do token
      final role = JwtDecoder.getUserRoleFromToken(token); // Papel do utilizador
      final id = JwtDecoder.getUserIdFromToken(token); // ID do utilizador

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
        Uri.parse('https://pi4-3soq.onrender.com/reports/user/$id'),
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
      // Ignora erros
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

  // Cores para o estado do relatório
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

  // Label para o estado do relatório
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
    // Constrói a interface da página
    return Scaffold(
      backgroundColor: const Color(0xFF262626), // Cor de fundo
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030), // Cor da AppBar
        automaticallyImplyLeading: false, // Remove botão de voltar
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
                onPressed: _showFiltroEstadoDialog, // Abre filtro de estado
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white)) // Loader
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
                          final relatorio = filteredRelatorios[index]; // Relatório atual
                          final String estado = relatorio['status'] ?? "N/A"; // Estado
                          final DateTime? data = relatorio['reportDate'] != null
                              ? DateTime.tryParse(relatorio['reportDate'])
                              : null; // Data do relatório

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 20),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Título com data
                                        Text(
                                          'Relatório - ${data != null ? "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}" : "Sem data"}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Nome do atleta
                                        Text(
                                          relatorio['athlete']?['name'] ?? 'Sem Nome',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Estado do relatório
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

  // Mostra o dialog para filtrar por estado
  void _showFiltroEstadoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                // Botão para filtrar por Pendente
                _FiltroEstadoButton(
                  label: 'Pendente',
                  onTap: () {
                    setState(() => filtroEstado = 'Pendente');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Botão para filtrar por Aprovado
                _FiltroEstadoButton(
                  label: 'Aprovado',
                  onTap: () {
                    setState(() => filtroEstado = 'Aprovado');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Botão para filtrar por Reprovado
                _FiltroEstadoButton(
                  label: 'Reprovado',
                  onTap: () {
                    setState(() => filtroEstado = 'Reprovado');
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Botão para limpar filtro
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

// Botão customizado para o filtro de estado
class _FiltroEstadoButton extends StatelessWidget {
  final String label; // Texto do botão
  final VoidCallback onTap; // Função ao clicar
  final bool isClear; // Indica se é botão de limpar

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