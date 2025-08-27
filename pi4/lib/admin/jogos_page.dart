import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../autenticacao/auth_service.dart';
import '../autenticacao/jwt_decode.dart';

class JogosPage extends StatefulWidget {
  final int idCategoriaEtaria;
  final String categoriaNome;

  const JogosPage({
    super.key,
    required this.idCategoriaEtaria,
    required this.categoriaNome,
  });

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> {
  List<dynamic> jogos = [];
  bool isLoadingJogos = true;
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
      _loadJogos();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _loadJogos() async {
    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};

    final String url =
        'https://pi4-backend-r17y.onrender.com/jogos/categoria/${widget.idCategoriaEtaria}';

    try {
      final response = await http.get(Uri.parse(url), headers: config);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          jogos = data;
          isLoadingJogos = false;
        });
      } else {
        setState(() {
          isLoadingJogos = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingJogos = false;
      });
    }
  }

  Future<void> _deleteJogo(int idJogo) async {
    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.delete(
        Uri.parse('https://pi4-backend-r17y.onrender.com/jogos/$idJogo'),
        headers: config,
      );

      if (response.statusCode == 200) {
        setState(() {
          jogos.removeWhere((jogo) => jogo['idJogo'] == idJogo);
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

  void _showGameDetails(dynamic jogo) {
    final equipaCasa = jogo['equipas'].firstWhere(
      (e) => e['papel'] == 'casa',
      orElse: () => {'nomeEquipa': 'N/A'},
    )['nomeEquipa'];

    final equipaVisitante = jogo['equipas'].firstWhere(
      (e) => e['papel'] == 'visitante',
      orElse: () => {'nomeEquipa': 'N/A'},
    )['nomeEquipa'];

    final dataJogo = jogo['dataJogo'] != null
        ? DateTime.parse(jogo['dataJogo'])
        : DateTime.now();
    final dataFormatada = DateFormat('dd/MM/yyyy').format(dataJogo);
    final horaFormatada = DateFormat('HH:mm').format(dataJogo);

    final concelho = jogo['concelho'] ?? 'N/A';
    final distrito = jogo['distrito'] ?? 'N/A';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2C), // Fundo escuro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bordas arredondadas
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
                    fontSize: 20,
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
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                // Concelho
                Text(
                  'Concelho: $concelho',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Distrito
                Text(
                  'Distrito: $distrito',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Data
                Text(
                  'Data: $dataFormatada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Hora
                Text(
                  'Hora: $horaFormatada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Botões
                if (userRole == 'Admin') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botão Eliminar
                      TextButton.icon(
                        onPressed: () async {
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
                            await _deleteJogo(jogo['idJogo']);
                            Navigator.of(context).pop(); // Fechar popup
                          }
                        },
                        icon: const Icon(
                          Icons.delete, // Ícone de lixeira
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
      appBar: AppBar(
        title: Text('Jogos - ${widget.categoriaNome}'),
        backgroundColor: const Color(0xFF000000),
        automaticallyImplyLeading: false, // <-- remove a seta de voltar
      ),
      backgroundColor: const Color(0xFF2C2C2C),
      body: Column(
        children: [
          const SizedBox(height: 16),
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
                            final String equipaCasa =
                                jogo['equipas'][0]['nomeEquipa'];
                            final String equipaVisitante =
                                jogo['equipas'][1]['nomeEquipa'];
                            final DateTime dataJogo =
                                DateTime.parse(jogo['dataJogo']);
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
                                      color: Colors.black,
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
        ],
      ),
    );
  }
}
