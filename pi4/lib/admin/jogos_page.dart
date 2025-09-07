import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../autenticacao/auth_service.dart';
import '../autenticacao/jwt_decode.dart';

// Página que mostra os jogos de uma categoria de idade
class JogosPage extends StatefulWidget {
  final int idAgeCategory; // ID do escalão
  final String categoriaNome; // Nome do escalão

  const JogosPage({
    super.key,
    required this.idAgeCategory,
    required this.categoriaNome,
  });

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> {
  List<dynamic> jogos = []; // Lista de jogos carregados
  bool isLoadingJogos = true; // Estado de carregamento
  String? userRole; // Role do utilizador (Admin, User, etc.)

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carrega dados do utilizador e jogos ao iniciar
  }

  // Carrega o token e obtém a role do utilizador
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
      _loadJogos(); // Carrega os jogos após obter a role
      // ignore: empty_catches
    } catch (e) {}
  }

  // Carrega os jogos do backend para o escalão selecionado
  Future<void> _loadJogos() async {
    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};

    final String url =
        'https://pi4-3soq.onrender.com/matches/category/${widget.idAgeCategory}';

    try {
      final response = await http.get(Uri.parse(url), headers: config);

      print('DEBUG status: ${response.statusCode}');
      print('DEBUG body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // DEBUG extra: mostra as equipas de cada jogo
        for (var jogo in data) {
          print('JOGO ID: ${jogo['idMatch']}');
          print('TEAMS: ${jogo['teams']}');
          for (var team in (jogo['teams'] ?? [])) {
            print('  role: ${team['role']} | teamName: ${team['teamName']}');
          }
        }

        setState(() {
          jogos = data;
          isLoadingJogos = false;
        });
      } else {
        setState(() {
          isLoadingJogos = false;
        });
        print('DEBUG erro ao carregar jogos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingJogos = false;
      });
      print('DEBUG exceção ao carregar jogos: $e');
    }
  }

  // Elimina um jogo do backend (apenas para admin)
  Future<void> _deleteJogo(int idMatch) async {
    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.delete(
        Uri.parse('https://pi4-3soq.onrender.com/matches/$idMatch'),
        headers: config,
      );

      if (response.statusCode == 200) {
        setState(() {
          jogos.removeWhere((jogo) => jogo['idMatch'] == idMatch);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo eliminado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao eliminar o jogo. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao eliminar o jogo: $e')),
      );
    }
  }

  // Mostra detalhes do jogo num popup
  void _showGameDetails(dynamic jogo) {
    final equipaCasa = jogo['teams'].firstWhere(
      (e) => e['role'] == 'casa',
      orElse: () => {'teamName': 'N/A'},
    )['teamName'];

    final equipaVisitante = jogo['teams'].firstWhere(
      (e) => e['role'] == 'visitante',
      orElse: () => {'teamName': 'N/A'},
    )['teamName'];

    final dataJogo = jogo['matchDate'] != null
        ? DateTime.parse(jogo['matchDate'])
        : DateTime.now();
    final dataFormatada = DateFormat('dd/MM/yyyy').format(dataJogo);
    final horaFormatada = DateFormat('HH:mm').format(dataJogo);

    final concelho = jogo['county'] ?? 'N/A';
    final distrito = jogo['district'] ?? 'N/A';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Equipa Casa
                Text(
                  equipaCasa,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                // "vs"
                const Text(
                  'vs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                // Equipa Visitante
                Text(
                  equipaVisitante,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 16),
                // Concelho
                Text(
                  'Concelho: $concelho',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Distrito
                Text(
                  'Distrito: $distrito',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Data
                Text(
                  'Data: $dataFormatada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Hora
                Text(
                  'hora: $horaFormatada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Botão Eliminar (apenas para admin)
                if (userRole == 'Admin')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Confirmação antes de eliminar
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Tens a certeza?'),
                                content: const Text(
                                    'Queres mesmo eliminar este jogo?'),
                                backgroundColor: const Color(0xFF2C2C2C),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await _deleteJogo(jogo['idMatch']);
                            Navigator.of(context).pop(); // Fechar popup
                          }
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Título da página
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
            // Lista de jogos
            Expanded(
                child: isLoadingJogos
                    ? const Center(child: CircularProgressIndicator())
                    : jogos.isEmpty
                        ? const Center(
                            child: Text(
                              'Sem jogos disponíveis.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: jogos.length,
                            itemBuilder: (context, index) {
                              final jogo = jogos[index];
                              // Obtém nome das equipas
                              final equipaCasa =
                                  (jogo['teams'] as List).firstWhere(
                                (e) => e['role'] == 'casa',
                                orElse: () => {'teamName': 'N/A'},
                              )['teamName'];

                              final equipaVisitante =
                                  (jogo['teams'] as List).firstWhere(
                                (e) => e['role'] == 'visitante',
                                orElse: () => {'teamName': 'N/A'},
                              )['teamName'];
                              final DateTime dataJogo =
                                  DateTime.parse(jogo['matchDate']);
                              final String dataFormatada =
                                  DateFormat('dd/MM/yyyy').format(dataJogo);

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                color: const Color(0xFF121212),
                                child: ListTile(
                                  title: Text(
                                    '$equipaCasa vs $equipaVisitante',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    child: Text(
                                      dataFormatada,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    // Chama a função para mostrar detalhes do jogo
                                    _showGameDetails(jogo);
                                  },
                                ),
                              );
                            },
                          )),

            // Barra inferior com botão para voltar à página anterior
            Container(
              width: double.infinity,
              color: const Color(0xFF2C2C2C),
              child: IconButton(
                icon:
                    const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
                onPressed: () {
                  Navigator.pop(context); // Ou navega para DashboardPage
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}