import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';
import '../autenticacao/jwt_decode.dart';

class CriarRelatorioPage extends StatefulWidget {
  final int idAthlete;

  const CriarRelatorioPage({super.key, required this.idAthlete});

  @override
  CriarRelatorioPageState createState() => CriarRelatorioPageState();
}

class CriarRelatorioPageState extends State<CriarRelatorioPage> {
  final String apiUrl = 'https://pi4-3soq.onrender.com';
  bool isLoading = false;

  final Map<String, dynamic> formData = {
    'technique': 1,
    'speed': 1,
    'competitiveAttitude': 1,
    'intelligence': 1,
    'height': 'Baixo',
    'morphology': 'Ectomorfo',
    'finalRating': 1,
    'freeText': '',
  };

  Future<void> submitReport() async {
    final shouldSubmit = await showDialog<bool>(
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
            'Vai submeter o relatório,\ntem a certeza?',
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

    if (shouldSubmit != true) {
      return; // Cancelar submissão se o usuário selecionar "Cancelar"
    }

    setState(() {
      isLoading = true;
    });

    final token = await AuthService().getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Token não encontrado. Faça login novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final idUtilizador = JwtDecoder.getUserIdFromToken(token);
      final Map<String, dynamic> dataToSend = {
        ...formData,
        'idUser': idUtilizador,
      };

      final response = await http.post(
        Uri.parse('$apiUrl/reports/${widget.idAthlete}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dataToSend),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Relatorio criado com sucesso!'),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Erro desconhecido.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao submeter relatório: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void incrementField(String field) {
    setState(() {
      if (formData[field] < 4) formData[field] += 1;
    });
  }

  void decrementField(String field) {
    setState(() {
      if (formData[field] > 1) {
        formData[field] -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double finalRating = _calculateFinalRating();

    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Criar relatório',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 90),
            child: Column(
              children: [
                _buildDropdownField(
                    'Técnica', 'technique', ['1', '2', '3', '4']),
                const SizedBox(height: 12),
                _buildDropdownField(
                    'Velocidade', 'speed', ['1', '2', '3', '4']),
                const SizedBox(height: 12),
                _buildDropdownField('Atitude competitiva',
                    'competitiveAttitude', ['1', '2', '3', '4']),
                const SizedBox(height: 12),
                _buildDropdownField(
                    'Inteligência', 'intelligence', ['1', '2', '3', '4']),
                const SizedBox(height: 12),
                _buildDropdownField('Morfologia', 'morphology',
                    ['Ectomorfo', 'Mesomorfo', 'Endomorfo']),
                const SizedBox(height: 12),
                _buildDropdownField(
                    'Altura', 'height', ['Baixo', 'Médio', 'Alto']),
                const SizedBox(height: 12),
                _buildTextField('Texto livre', 'freeText'),
                const SizedBox(height: 18),
                // Rating final
                _buildDropdownField('Rating final', 'finalRating', ['1', '2', '3', '4']),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              formData['finalRating'] = finalRating;
                            });
                            submitReport();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Avaliar',
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
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          // Barra Home fixa no fundo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFF303030),
              child: IconButton(
                icon:
                    const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

// Calcula a média dos 4 campos principais (1 a 4)
  double _calculateFinalRating() {
    final values = [
      int.tryParse(formData['technique'].toString()) ?? 1,
      int.tryParse(formData['speed'].toString()) ?? 1,
      int.tryParse(formData['competitiveAttitude'].toString()) ?? 1,
      int.tryParse(formData['intelligence'].toString()) ?? 1,
    ];
    return values.reduce((a, b) => a + b) / values.length;
  }

// --- NOVOS WIDGETS DE ESTILO ---

  Widget _buildDropdownField(String label, String field, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            value: formData[field]?.toString(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            dropdownColor: const Color(0xFFE6E6E6),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            onChanged: (value) {
              setState(() {
                formData[field] = value!;
              });
            },
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            style: const TextStyle(color: Colors.black),
            onChanged: (value) {
              setState(() {
                formData[field] = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
