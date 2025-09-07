import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';

// Página para atribuir uma nova tarefa a um olheiro
class AddTarefaPage extends StatefulWidget {
  const AddTarefaPage({super.key});

  @override
  State<AddTarefaPage> createState() => _AddTarefaPageState();
}

class _AddTarefaPageState extends State<AddTarefaPage> {
  // Listas para dropdowns
  List<dynamic> jogos = [];
  List<dynamic> atletas = [];
  List<dynamic> utilizadores = [];

  // Valores selecionados nos dropdowns
  String? selectedJogo;
  String? selectedAtleta;
  String? selectedUtilizador;
  // Campos de texto
  String titulo = '';
  String descricao = '';

  // Estado de carregamento
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Carrega dados ao iniciar a página
  }

  // Busca jogos, atletas e olheiros do backend
  Future<void> _fetchData() async {
    try {
      final token = await AuthService().getToken();
      final config = {'Authorization': 'Bearer $token'};

      // Faz chamadas paralelas para buscar jogos, atletas e utilizadores
      final responses = await Future.wait([
        http.get(Uri.parse('https://pi4-3soq.onrender.com/matches'),
            headers: config),
        http.get(Uri.parse('https://pi4-3soq.onrender.com/athletes'),
            headers: config),
        http.get(Uri.parse('https://pi4-3soq.onrender.com/auth/users'),
            headers: config),
      ]);

      // Se todas as respostas forem OK, atualiza as listas
      if (responses.every((res) => res.statusCode == 200)) {
        final jogosData = json.decode(responses[0].body);
        final atletasData = json.decode(responses[1].body);
        final utilizadoresData = json.decode(responses[2].body);

        // Filtra apenas os olheiros (idUserType == 3)
        final olheiros =
            utilizadoresData.where((user) => user['idUserType'] == 3).toList();

        setState(() {
          jogos = jogosData;
          atletas = atletasData;
          utilizadores = olheiros;
        });
      } else {
        _showError('Erro ao carregar dados.');
      }
    } catch (e) {
      _showError('Erro ao conectar ao servidor.');
    }
  }

  // Cria a tarefa no backend
  Future<void> _createTarefa() async {
    // Validação dos campos obrigatórios
    if (selectedJogo == null ||
        selectedAtleta == null ||
        selectedUtilizador == null) {
      _showError('Todos os campos são obrigatórios.');
      return;
    }

    // Exibe o popup de confirmação
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232323),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding:
              const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
          contentPadding:
              const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
          title: const Text(
            'Vai criar uma tarefa nova,\ntem a certeza?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botão de confirmação
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sim',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                // Botão de cancelar
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D9D9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Não',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    // Se o usuário cancelar, interrompe o processo
    if (confirm != true) {
      return;
    }

    // Prossegue com a criação da tarefa
    setState(() {
      isLoading = true;
    });

    final token = await AuthService().getToken();
    final config = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Corpo do pedido para criar tarefa
    final body = json.encode({
      'idMatch': selectedJogo,
      'idAthlete': selectedAtleta,
      'idUser': selectedUtilizador,
      'title': titulo,
      'description': descricao,
    });

    try {
      final response = await http.post(
        Uri.parse('https://pi4-3soq.onrender.com/tasks'),
        headers: config,
        body: body,
      );

      // Mostra mensagem de sucesso ou erro
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tarefa atribuida com sucesso!'),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _showError('Erro ao criar a tarefa.');
      }
    } catch (e) {
      _showError('Erro ao conectar ao servidor.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Mostra erro no SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF303030),
          elevation: 0,
          centerTitle: true, // centra o título
          automaticallyImplyLeading: false,
          title: const Text(
            "Atribuir Tarefa",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight, // Altura mínima
                    ),
                    child: IntrinsicHeight(
                      child: Container(
                        color: const Color(0xFF262626), // Fundo escuro do corpo
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Dropdown para selecionar o jogo
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Selecione um Jogo',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .never, // Não flutuar o texto
                                filled: true,
                                fillColor: Color.fromARGB(
                                    255, 134, 133, 133), // Fundo escuro
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              dropdownColor: const Color(
                                  0xFF121212), // Cor do menu dropdown
                              style: const TextStyle(color: Colors.white),
                              value: selectedJogo,
                              items: jogos.map((jogo) {
                                // Mostra nome das equipas no dropdown
                                final teams = jogo['teams'] ?? [];
                                final equipaCasa = teams.firstWhere(
                                  (e) => e['role'] == 'casa',
                                  orElse: () => {
                                    'team': {'name': 'Casa?'}
                                  },
                                );
                                final equipaVisitante = teams.firstWhere(
                                  (e) => e['role'] == 'visitante',
                                  orElse: () => {
                                    'team': {'name': 'Visitante?'}
                                  },
                                );
                                final nomeCasa =
                                    equipaCasa['team']?['name'] ?? 'Casa?';
                                final nomeVisitante = equipaVisitante['team']
                                        ?['name'] ??
                                    'Visitante?';
                                final idMatch = (jogo['match']?['idMatch'] ??
                                        jogo['idMatch'])
                                    .toString();
                                return DropdownMenuItem(
                                  value: idMatch,
                                  child: Text('$nomeCasa vs $nomeVisitante'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedJogo = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Dropdown para selecionar atleta
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Selecione um Atleta',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .never, // Não flutuar o texto
                                filled: true,
                                fillColor: Color.fromARGB(
                                    255, 134, 133, 133), // Fundo escuro
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              dropdownColor: const Color(
                                  0xFF121212), // Cor do menu dropdown
                              style: const TextStyle(color: Colors.white),
                              value: selectedAtleta,
                              items: atletas.map((atleta) {
                                return DropdownMenuItem(
                                  value: atleta['idAthlete'].toString(),
                                  child: Text(atleta['name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedAtleta = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Dropdown para selecionar olheiro
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Selecione um Utilizador',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .never, // Não flutuar o texto
                                filled: true,
                                fillColor: Color.fromARGB(
                                    255, 134, 133, 133), // Fundo escuro
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              dropdownColor: const Color(
                                  0xFF121212), // Cor do menu dropdown
                              style: const TextStyle(color: Colors.white),
                              value: selectedUtilizador,
                              items: utilizadores.map((user) {
                                return DropdownMenuItem(
                                  value: user['idUser'].toString(),
                                  child: Text(user['name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedUtilizador = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Campo de texto para título da tarefa
                            TextField(
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Título da Tarefa',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .never, // Não flutuar o texto
                                filled: true,
                                fillColor: Color(0xFFE6E6E6), // Fundo claro
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  titulo = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Campo de texto para descrição da tarefa
                            TextField(
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Descrição da Tarefa',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .never, // Não flutuar o texto
                                filled: true,
                                fillColor: Color(0xFFE6E6E6), // Fundo claro
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 3,
                              onChanged: (value) {
                                setState(() {
                                  descricao = value;
                                });
                              },
                            ),
                            const Spacer(),
                            const SizedBox(
                                height:
                                    30), // Garante que o botão fique no final
                            // Botão para criar a tarefa
                            ElevatedButton(
                              onPressed: _createTarefa,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFDD522),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Atribuir Tarefa',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Barra inferior com botão para voltar à página anterior
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
        ]));
  }
}