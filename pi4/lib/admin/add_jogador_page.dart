import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';

class AddAtletaPage extends StatefulWidget {
  const AddAtletaPage({super.key});

  @override
  AddAtletaPageState createState() => AddAtletaPageState();
}

class AddAtletaPageState extends State<AddAtletaPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataNascimentoController =
      TextEditingController();
  final TextEditingController nacionalidadeController = TextEditingController();
  final TextEditingController naturalidadeController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  String? selectedPosicao;
  String? selectedEncarregado;
  String? selectedEquipa;
  bool isLoading = false;
  String mensagem = '';

  List<dynamic> posicoes = [];
  List<dynamic> equipas = [];
  List<dynamic> encarregados = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Função para carregar os dados das posições, equipas e encarregados
  Future<void> _loadData() async {
    try {
      final token = await AuthService().getToken();

      final responsePosicoes = await http.get(
        Uri.parse('https://pi4-3soq.onrender.com/positions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final responseEquipas = await http.get(
        Uri.parse('https://pi4-3soq.onrender.com/teams'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final responseEncarregados = await http.get(
        Uri.parse('https://pi4-3soq.onrender.com/guardians'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return; // Verifica se o widget está montado

      if (responsePosicoes.statusCode == 200) {
        setState(() {
          posicoes = json.decode(responsePosicoes.body);
        });
      } else {}

      if (responseEquipas.statusCode == 200) {
        setState(() {
          equipas = json.decode(responseEquipas.body);
        });
      } else {}

      // DEBUG: Mostra status e body da resposta dos encarregados
      print('Encarregados status: ${responseEncarregados.statusCode}');
      print('Encarregados body: ${responseEncarregados.body}');

      if (responseEncarregados.statusCode == 200) {
        final data = json.decode(responseEncarregados.body);
        print('Encarregados decoded: $data');
        setState(() {
          encarregados = data; // data já é uma lista!
        });
      } else {
        print(
            'Erro ao buscar encarregados: ${responseEncarregados.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensagem = 'Erro ao carregar os dados.';
      });
      print('Erro no loadData: $e');
    }
  }

  // Função para adicionar o atleta
  Future<void> _addAtleta() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    if (nomeController.text.isEmpty ||
        dataNascimentoController.text.isEmpty ||
        nacionalidadeController.text.isEmpty ||
        naturalidadeController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Todos os campos obrigatórios devem ser preenchidos!'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    final confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // ...no teu showDialog...
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
            'Vai adicionar um jogador novo,\ntem a certeza?',
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

    if (confirm == true) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final atleta = {
        'name': nomeController.text,
        'birthDate': dataNascimentoController.text,
        'nationality': nacionalidadeController.text,
        'birthplace': naturalidadeController.text,
        if (selectedPosicao != null && selectedPosicao != '')
          'idPosition': int.tryParse(selectedPosicao!), // <-- converte para int
        if (selectedEncarregado != null && selectedEncarregado != '')
          'idGuardian': int.tryParse(selectedEncarregado!),
        if (selectedEquipa != null && selectedEquipa != '')
          'idTeam': int.tryParse(selectedEquipa!),
        'link': linkController.text.isNotEmpty ? linkController.text : '',
      };

      print('DEBUG atleta: $atleta'); // <-- Mostra o corpo enviado

      try {
        final token = await AuthService().getToken();
        final response = await http.post(
          Uri.parse('https://pi4-3soq.onrender.com/athletes'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(atleta),
        );

        print('DEBUG status: ${response.statusCode}'); // <-- Mostra status
        print('DEBUG body: ${response.body}'); // <-- Mostra resposta

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Atleta adicionado com sucesso!'),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erro ao adicionar Jogador: ${response.body}')),
          );
        }
      } catch (e) {
        print('DEBUG exception: $e'); // <-- Mostra exceção
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor')),
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        elevation: 0,
        centerTitle: true, // <-- centra o título
        automaticallyImplyLeading: false,
        title: const Text(
          "Adicionar Jogador",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Container(
                        color: const Color(0xFF262626),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextField('Nome', nomeController),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  _buildTextField(
                                    'Data de nascimento',
                                    dataNascimentoController,
                                    enabled: false,
                                  ),
                                  const Positioned(
                                    right: 16,
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                                'Nacionalidade', nacionalidadeController),
                            const SizedBox(height: 10),
                            _buildTextField(
                                'Naturalidade', naturalidadeController),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedPosicao,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 125, 123, 123),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              hint: const Text(
                                'Posição (opcional)',
                                style: TextStyle(color: Colors.black),
                              ),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.black),
                              iconEnabledColor: Colors.black,
                              iconDisabledColor: Colors.black,
                              items: [
                                if (selectedPosicao == null)
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'Posição (opcional)',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ...posicoes.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item['id'].toString(),
                                    child: Text(
                                      item['name'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedPosicao = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedEncarregado,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 125, 123, 123),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              hint: const Text(
                                'Encarregado (opcional)',
                                style: TextStyle(color: Colors.black),
                              ),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.black),
                              iconEnabledColor: Colors.black,
                              iconDisabledColor: Colors.black,
                              items: [
                                if (selectedEncarregado == null)
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'Encarregado (opcional)',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ...encarregados.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item['idGuardian'].toString(),
                                    child: Text(
                                      item['name'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedEncarregado = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedEquipa,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 125, 123, 123),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              hint: const Text(
                                'Equipa (opcional)',
                                style: TextStyle(color: Colors.black),
                              ),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.black),
                              iconEnabledColor: Colors.black,
                              iconDisabledColor: Colors.black,
                              items: [
                                if (selectedEquipa == null)
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'Equipa (opcional)',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ...equipas.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item['idTeam'].toString(),
                                    child: Text(
                                      item['name'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedEquipa = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildTextField('Link (opcional)', linkController),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: isLoading ? null : _addAtleta,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Adicionar jogador',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Botão home fixo no fundo
              Container(
                width: double.infinity,
                color: const Color(0xFF303030),
                child: IconButton(
                  icon: const Icon(Icons.home,
                      color: Color(0xFFFFD700), size: 36),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: controller.text.isEmpty
            ? hint
            : null, // Mostra o hint apenas se vazio
        hintStyle: const TextStyle(color: Colors.black),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        // Este método será chamado ao digitar, mas o TextField já atualiza dinamicamente.
      },
    );
  }

  // Função para exibir o DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dataNascimentoController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }
}
