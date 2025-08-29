import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';
import '../autenticacao/jwt_decode.dart';

class CriarRelatorioPage extends StatefulWidget {
  final int idAtleta;

  const CriarRelatorioPage({super.key, required this.idAtleta});

  @override
  CriarRelatorioPageState createState() => CriarRelatorioPageState();
}

class CriarRelatorioPageState extends State<CriarRelatorioPage> {
  final String apiUrl = 'https://pi4-backend-r17y.onrender.com';
  bool isLoading = false;

  final Map<String, dynamic> formData = {
    'tecnica': 1,
    'velocidade': 1,
    'atitudeCompetitiva': 1,
    'inteligencia': 1,
    'altura': 'Baixo',
    'morfologia': 'Ectomorfo',
    'ratingFinal': 1,
    'textoLivre': '',
  };

  Future<void> submitReport() async {
    final shouldSubmit = await showDialog<bool>(
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
                Icons.help_outline, // Ícone de interrogação
                color: Colors.orange,
                size: 50, // Tamanho do ícone
              ),
              const SizedBox(height: 16),
              const Text(
                'Tens a certeza que desejas submeter este relatório?',
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
            // Botão "Sim, submeter"
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
                'Sim, submeter!',
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
        'idUtilizador': idUtilizador,
      };

      final response = await http.post(
        Uri.parse('$apiUrl/relatorios/${widget.idAtleta}'),
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
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        title: const Text('Avaliações'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildRatingCard('Técnica', 'tecnica'),
                  buildRatingCard('Velocidade', 'velocidade'),
                  buildRatingCard('Inteligência', 'inteligencia'),
                  buildRatingCard('Atitude Competitiva', 'atitudeCompetitiva'),
                  buildDropdownField('Morfologia', 'morfologia',
                      ['Ectomorfo', 'Mesomorfo', 'Endomorfo']),
                  buildDropdownField(
                      'Altura', 'altura', ['Baixo', 'Médio', 'Alto']),
                  buildRatingCard('Rating Final', 'ratingFinal'),
                  buildTextField('Texto Livre', 'textoLivre'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(
                          50), // Define altura e largura total
                    ),
                    child: const Text(
                      'Submeter',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildRatingCard(String label, String field) {
    return Card(
      color: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toLowerCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.yellow),
                  onPressed: () => decrementField(field),
                ),
                Text(
                  '${formData[field]}',
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.yellow),
                  onPressed: () => incrementField(field),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownField(String label, String field, List<String> options) {
    return Card(
      color: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          dropdownColor: const Color(0xFF121212),
          value: formData[field],
          onChanged: (value) {
            setState(() {
              formData[field] = value!;
            });
          },
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String field) {
    return Card(
      color: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              formData[field] = value;
            });
          },
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
