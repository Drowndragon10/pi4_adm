import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:http/http.dart' as http; // Importa o pacote http para requisições HTTP
import 'dart:convert'; // Importa para codificação/decodificação JSON
import 'package:intl/intl.dart'; // Importa para formatação de datas
import '../autenticacao/auth_service.dart'; // Serviço de autenticação
import '../autenticacao/jwt_decode.dart'; // Utilitário para decodificar JWT

// Página de jogos para o olheiro
class JogosOlheiroPage extends StatefulWidget {
  final int idAgeCategory; // ID da categoria etária
  final String categoriaNome; // Nome da categoria

  const JogosOlheiroPage({
    super.key,
    required this.idAgeCategory,
    required this.categoriaNome,
  });

  @override
  State<JogosOlheiroPage> createState() => _JogosOlheiroPageState();
}

// Estado da página de jogos do olheiro
class _JogosOlheiroPageState extends State<JogosOlheiroPage> {
  List<dynamic> jogos = []; // Lista de jogos carregados
  bool isLoadingJogos = true; // Indica se está carregando os jogos
  String? userRole; // Papel do utilizador (ex: admin, olheiro, etc)

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carrega dados do utilizador ao iniciar
  }

  // Carrega dados do utilizador (token e role)
  Future<void> _loadUserData() async {
    try {
      final token = await AuthService().getToken(); // Obtém o token
      if (token == null) {
        return;
      }

      // Decodifica o token para obter a role do utilizador
      final role = JwtDecoder.getUserRoleFromToken(token);
      setState(() {
        userRole = role;
      });
      _loadJogos(); // Carrega os jogos após obter a role
      // ignore: empty_catches
    } catch (e) {}
  }

  // Carrega os jogos da API
  Future<void> _loadJogos() async {
    final token = await AuthService().getToken(); // Obtém o token
    final config = {'Authorization': 'Bearer $token'}; // Header de autorização

    final String url =
        'https://pi4-3soq.onrender.com/matches/category/${widget.idAgeCategory}'; // URL da API

    try {
      final response = await http.get(Uri.parse(url), headers: config); // Faz o GET

      print('DEBUG status: ${response.statusCode}');
      print('DEBUG body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body); // Decodifica o JSON

        // DEBUG extra: mostra as equipas de cada jogo
        for (var jogo in data) {
          print('JOGO ID: ${jogo['idMatch']}');
          print('TEAMS: ${jogo['teams']}');
          for (var team in (jogo['teams'] ?? [])) {
            print('  role: ${team['role']} | teamName: ${team['teamName']}');
          }
        }

        setState(() {
          jogos = data; // Atualiza a lista de jogos
          isLoadingJogos = false; // Finaliza o loading
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

  // Mostra detalhes do jogo num dialog
  void _showGameDetails(dynamic jogo) {
    // Obtém o nome da equipa da casa
    final equipaCasa = jogo['teams'].firstWhere(
      (e) => e['role'] == 'casa',
      orElse: () => {'teamName': 'N/A'},
    )['teamName'];

    // Obtém o nome da equipa visitante
    final equipaVisitante = jogo['teams'].firstWhere(
      (e) => e['role'] == 'visitante',
      orElse: () => {'teamName': 'N/A'},
    )['teamName'];

    // Formata a data e hora do jogo
    final dataJogo = jogo['matchDate'] != null
        ? DateTime.parse(jogo['matchDate'])
        : DateTime.now();
    final dataFormatada = DateFormat('dd/MM/yyyy').format(dataJogo);
    final horaFormatada = DateFormat('HH:mm').format(dataJogo);

    // Obtém concelho e distrito
    final concelho = jogo['county'] ?? 'N/A';
    final distrito = jogo['district'] ?? 'N/A';

    // Mostra o dialog com os detalhes
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
                // Botão Fechar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o dialog
                  },
                  child: const Text(
                    'Fechar',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
      backgroundColor: const Color(0xFF232323), // Cor de fundo
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Cabeçalho com o título "Jogos"
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
                    ? const Center(child: CircularProgressIndicator()) // Loader
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
                              // Obtém equipa da casa
                              final equipaCasa =
                                  (jogo['teams'] as List).firstWhere(
                                (e) => e['role'] == 'casa',
                                orElse: () => {'teamName': 'N/A'},
                              )['teamName'];

                              // Obtém equipa visitante
                              final equipaVisitante =
                                  (jogo['teams'] as List).firstWhere(
                                (e) => e['role'] == 'visitante',
                                orElse: () => {'teamName': 'N/A'},
                              )['teamName'];
                              // Data do jogo
                              final DateTime dataJogo =
                                  DateTime.parse(jogo['matchDate']);
                              final String dataFormatada =
                                  DateFormat('dd/MM/yyyy').format(dataJogo);

                              // Card de cada jogo
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
            // Botão Home fixo no fundo
            Container(
              width: double.infinity,
              color: const Color(0xFF2C2C2C),
              child: IconButton(
                icon:
                    const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
                onPressed: () {
                  Navigator.pop(context); // Volta para a página anterior
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}