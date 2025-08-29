import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'relatorios_submetidos.dart';
import 'dart:convert';
import '../autenticacao/auth_service.dart';
import '../autenticacao/jwt_decode.dart';
import 'add_report_page.dart'; // Página para criar relatório
import 'package:intl/intl.dart';

class MinhasTarefasPage extends StatefulWidget {
  const MinhasTarefasPage({super.key});

  @override
  State<MinhasTarefasPage> createState() => _MinhasTarefasPageState();
}

class _MinhasTarefasPageState extends State<MinhasTarefasPage> {
  List<dynamic> tarefas = [];
  List<dynamic> jogos = [];
  String? userRole;
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      return;
    }

    try {
      final role = JwtDecoder.getUserRoleFromToken(token);
      final id = JwtDecoder.getUserIdFromToken(token);

      setState(() {
        userRole = role;
        userId = id;
      });

      await _loadTarefas();
      await _loadJogos();
      // ignore: empty_catches
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTarefas() async {
    final token = await AuthService().getToken();

    try {
      final response = await http.get(
        Uri.parse('https://pi4-3soq.onrender.com/tasks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tarefas = data.where((tarefa) => tarefa['idUser'] == userId).toList();
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _loadJogos() async {
    final token = await AuthService().getToken();

    try {
      final response = await http.get(
        Uri.parse('https://pi4-3soq.onrender.com/matches'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          jogos = json.decode(response.body);
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  String _getEquipasDoJogo(int idJogo) {
    final jogo = jogos.firstWhere(
      (j) => j['match']['idMatch'] == idJogo,
      orElse: () {
        return {};
      },
    );

    if (jogo.isNotEmpty) {
      final equipaCasa = (jogo['teams'] as List).firstWhere(
        (e) => e['role'] == 'casa',
        orElse: () {
          return {};
        },
      )['team']['name'];

      final equipaVisitante = (jogo['teams'] as List).firstWhere(
        (e) => e['role'] == 'visitante',
        orElse: () {
          return {};
        },
      )['team']['name'];

      return '$equipaCasa vs $equipaVisitante';
    }

    return 'Sem equipas';
  }

  void _criarRelatorio(int? idAtleta) {
    if (idAtleta != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CriarRelatorioPage(idAtleta: idAtleta),
        ),
      ).then((_) {
        _loadTarefas(); // Recarregar tarefas ao retornar da página de criação de relatório
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atleta não atribuído à tarefa!')),
      );
    }
  }

  void _mostrarDetalhesTarefa(Map<String, dynamic> tarefa) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Fundo transparente
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95, // Largura ajustada
            decoration: BoxDecoration(
              color: Colors.grey[850], // Fundo do popup
              borderRadius: BorderRadius.circular(16), // Bordas arredondadas
            ),
            padding: const EdgeInsets.all(16), // Espaçamento interno
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta à altura do conteúdo
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalhes: ${tarefa['title'] ?? "Sem título"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descrição: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tarefa['description'] ?? "Sem descrição",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Atleta: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tarefa['athlete']?['name'] ?? "Não atribuído",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jogo: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _getEquipasDoJogo(tarefa['idMatch'] ?? 0),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tarefa['taskDate'] != null
                            ? DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(tarefa['taskDate']).toLocal(),
                              )
                            : "Não disponível",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  // Alinha os botões ao centro
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _criarRelatorio(tarefa['athlete']?['idAthlete']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Criar Relatório'),
                      ),
                      const SizedBox(height: 8), // Espaço entre os botões
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.yellow,
                        ),
                        child: const Text('Ver mais tarde'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        title: const Text('Tarefas'),
        backgroundColor: const Color(0xFF303030),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : tarefas.isEmpty
                    ? const Center(
                        child: Text(
                          'Sem tarefas disponíveis.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTarefas,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          itemCount: tarefas.length,
                          itemBuilder: (context, index) {
                            final tarefa = tarefas[index];
                            return Card(
                              color: const Color(0xFF2C2C2C),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                title: Text(
                                  tarefa['title'] ?? 'Sem título',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      tarefa['description'] ?? 'Sem descrição',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tarefa['taskDate'] != null
                                          ? DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(
                                                      tarefa['taskDate'])
                                                  .toLocal())
                                          : 'Sem data',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _mostrarDetalhesTarefa(tarefa),
                              ),
                            );
                          },
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
                Navigator.pop(context); // Ou navega para DashboardPage
              },
            ),
          ),
        ],
      ),
    );
  }
}
