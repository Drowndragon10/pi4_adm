import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:http/http.dart' as http; // Importa o pacote http para requisições HTTP
import 'dart:convert'; // Importa para codificação/decodificação JSON
import '../autenticacao/auth_service.dart'; // Serviço de autenticação
import '../autenticacao/jwt_decode.dart'; // Utilitário para decodificar JWT
import 'add_report_page.dart'; // Página para criar relatório
import 'package:intl/intl.dart'; // Para formatação de datas

// Página principal das tarefas do olheiro
class MinhasTarefasPage extends StatefulWidget {
  const MinhasTarefasPage({super.key});

  @override
  State<MinhasTarefasPage> createState() => _MinhasTarefasPageState();
}

// Estado da página de tarefas
class _MinhasTarefasPageState extends State<MinhasTarefasPage> {
  List<dynamic> tarefas = []; // Lista de tarefas do utilizador
  List<dynamic> jogos = []; // Lista de jogos disponíveis
  String? userRole; // Papel do utilizador (ex: olheiro)
  int? userId; // ID do utilizador autenticado
  bool isLoading = true; // Indica se está carregando dados

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carrega dados do utilizador ao iniciar
  }

  // Carrega dados do utilizador autenticado (token, role, id)
  Future<void> _loadUserData() async {
    final authService = AuthService(); // Instancia o serviço de autenticação
    final token = await authService.getToken(); // Obtém o token

    if (token == null) {
      return;
    }

    try {
      final role = JwtDecoder.getUserRoleFromToken(token); // Extrai o papel do token
      final id = JwtDecoder.getUserIdFromToken(token); // Extrai o ID do token

      setState(() {
        userRole = role;
        userId = id;
      });

      await _loadTarefas(); // Carrega as tarefas do utilizador
      await _loadJogos(); // Carrega os jogos disponíveis
      // ignore: empty_catches
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false; // Finaliza o loading
      });
    }
  }

  // Carrega as tarefas do utilizador autenticado
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
          // Filtra apenas tarefas do utilizador autenticado
          tarefas = data.where((tarefa) => tarefa['idUser'] == userId).toList();
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  // Carrega todos os jogos disponíveis
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

  // Retorna string com as equipas de um jogo pelo id do jogo
  String _getEquipasDoJogo(int idJogo) {
    final jogo = jogos.firstWhere(
      (j) => j['match']['idMatch'] == idJogo,
      orElse: () {
        return {};
      },
    );

    if (jogo.isNotEmpty) {
      // Obtém equipa da casa
      final equipaCasa = (jogo['teams'] as List).firstWhere(
        (e) => e['role'] == 'casa',
        orElse: () {
          return {};
        },
      )['team']['name'];

      // Obtém equipa visitante
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

  // Navega para a página de criar relatório para o atleta da tarefa
  void _criarRelatorio(int? idAtleta) {
    if (idAtleta != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CriarRelatorioPage(idAthlete: idAtleta),
        ),
      ).then((_) {
        _loadTarefas(); // Recarrega tarefas ao retornar
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atleta não atribuído à tarefa!')),
      );
    }
  }

  // Mostra detalhes da tarefa num popup/dialog
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
                // Título do popup
                Text(
                  'Nova Tarefa!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                // Linha da descrição
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
                // Linha do atleta
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
                // Linha do jogo
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
                // Linha da data
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
                // Botões do popup
                Center(
                  child: Column(
                    children: [
                      // Botão para criar relatório
                      ElevatedButton(
                        onPressed: () =>
                            _criarRelatorio(tarefa['athlete']?['idAthlete']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, // Força o texto a bold
                            fontSize: 16,
                          ),
                        ),
                        child: const Text(
                          'Criar Relatório',
                          style: TextStyle(
                              fontWeight: FontWeight.bold), // Garante bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botão para fechar o popup
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        child: const Text('Fechar'),
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
    // Constrói a interface da página
    return Scaffold(
      backgroundColor: const Color(0xFF262626), // Cor de fundo
      appBar: AppBar(
        title: const Text('Tarefas'), // Título da AppBar
        backgroundColor: const Color(0xFF303030), // Cor da AppBar
        automaticallyImplyLeading: false, // Remove botão de voltar
        centerTitle: true, // Centraliza o título
        elevation: 0, // Remove sombra
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white), // Loader
                  )
                : tarefas.isEmpty
                    ? const Center(
                        child: Text(
                          'Sem tarefas disponíveis.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTarefas, // Permite atualizar a lista
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          itemCount: tarefas.length,
                          itemBuilder: (context, index) {
                            final tarefa = tarefas[index];
                            // Card de cada tarefa
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
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tarefa['title'] ?? 'Sem título',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      tarefa['taskDate'] != null
                                          ? DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(tarefa['taskDate'])
                                                  .toLocal())
                                          : 'Sem data',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    tarefa['description'] ?? 'Sem descrição',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                onTap: () => _mostrarDetalhesTarefa(tarefa), // Mostra detalhes ao clicar
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
                Navigator.pop(context); // Volta para a página anterior
              },
            ),
          ),
        ],
      ),
    );
  }
}