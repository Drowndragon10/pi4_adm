import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../autenticacao/auth_service.dart';

class AddJogoPage extends StatefulWidget {
  const AddJogoPage({super.key});

  @override
  State<AddJogoPage> createState() => _AddJogoPageState();
}

class _AddJogoPageState extends State<AddJogoPage> {
  List<dynamic> equipas = [];
  String? selectedEquipaCasa;
  String? selectedEquipaVisitante;
  String concelho = '';
  String distrito = '';
  DateTime? dataJogo;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEquipas();
  }

  // Função para buscar equipas do backend
  Future<void> _fetchEquipas() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('https://pi4-3soq.onrender.com/teams'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        equipas = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar equipas.')),
      );
    }
  }

  // Função para criar um novo jogo
  Future<void> _createJogo() async {
    if (selectedEquipaCasa == selectedEquipaVisitante) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'A equipa da casa e a equipa visitante não podem ser a mesma.'),
        ),
      );
      return;
    }

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212), // Fundo escuro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bordas arredondadas
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.help_outline, // Ícone de "?"
                color: Colors.orange,
                size: 50, // Ícone maior
              ),
              const SizedBox(height: 16),
              const Text(
                'Tens a certeza que desejas criar este jogo?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            // Botão "Sim, criar"
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sim, criar!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8), // Espaço entre os botões

            // Botão "Cancelar"
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Verifica se o utilizador confirmou a criação
    if (shouldCreate != true) {
      return;
    }

    final token = await AuthService().getToken();
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://pi4-3soq.onrender.com/matches'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'county': concelho,
        'district': distrito,
        'matchDate': DateFormat('yyyy-MM-ddTHH:mm:ss').format(dataJogo!),
        'teams': [
          {'idTeam': selectedEquipaCasa, 'role': 'casa'},
          {'idTeam': selectedEquipaVisitante, 'role': 'visitante'},
        ],
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('jogo adicionado com sucesso!'),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar o jogo.')),
      );
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
          "Adicionar Jogo",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'dd/mm/aaaa --:--',
                        filled: true,
                        fillColor: Color(0xFFE6E6E6),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                        ),
                      ),
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            dataJogo = selectedDate;
                          });
                        }
                      },
                      controller: TextEditingController(
                        text: dataJogo != null
                            ? DateFormat('dd/MM/yyyy').format(dataJogo!)
                            : '',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Concelho',
                        filled: true,
                        fillColor: Color(0xFFE6E6E6),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) => concelho = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Distrito',
                        filled: true,
                        fillColor: Color(0xFFE6E6E6),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) => distrito = value,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedEquipaCasa,
                      decoration: const InputDecoration(
                        hintText: 'Selecione a Equipa da Casa',
                        filled: true,
                        fillColor: Color(0xFFE6E6E6),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      dropdownColor: const Color(0xFF2C2C2C),
                      style: const TextStyle(color: Colors.black),
                      items: equipas.map((equipa) {
                        return DropdownMenuItem<String>(
                          value: equipa['idTeam'].toString(),
                          child: Text(equipa['name'],
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEquipaCasa = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedEquipaVisitante,
                      decoration: const InputDecoration(
                        hintText: 'Selecione a Equipa Visitante',
                        filled: true,
                        fillColor: Color(0xFFE6E6E6),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      dropdownColor: const Color(0xFF2C2C2C),
                      style: const TextStyle(color: Colors.black),
                      items: equipas.map((equipa) {
                        return DropdownMenuItem<String>(
                          value: equipa['idEquipa'].toString(),
                          child: Text(equipa['nome'],
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEquipaVisitante = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _createJogo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDD522),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Criar Jogo',
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
      bottomNavigationBar: Container(
        width: double.infinity,
        color: const Color(0xFF2C2C2C),
        child: IconButton(
          icon: const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
          onPressed: () {
            Navigator.pop(context); // Ou navega para DashboardPage
          },
        ),
      ),
    );
  }
}
