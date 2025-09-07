import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:http/http.dart' as http; // Importa o pacote http para requisições
import 'dart:convert'; // Importa para codificação/decodificação JSON
import '../autenticacao/auth_service.dart'; // Serviço de autenticação
import '../autenticacao/jwt_decode.dart'; // Utilitário para decodificar JWT

// Página para criar um novo relatório para um atleta
class CriarRelatorioPage extends StatefulWidget {
  final int idAthlete; // ID do atleta para o qual o relatório será criado

  const CriarRelatorioPage({super.key, required this.idAthlete});

  @override
  CriarRelatorioPageState createState() => CriarRelatorioPageState();
}

// Estado da página de criação de relatório
class CriarRelatorioPageState extends State<CriarRelatorioPage> {
  final String apiUrl = 'https://pi4-3soq.onrender.com'; // URL base da API
  bool isLoading = false; // Indica se está carregando (para mostrar o loader)

  // Dados do formulário, com valores iniciais
  final Map<String, dynamic> formData = {
    'technique': 1, // Técnica do atleta
    'speed': 1, // Velocidade do atleta
    'competitiveAttitude': 1, // Atitude competitiva
    'intelligence': 1, // Inteligência
    'height': 'Baixo', // Altura
    'morphology': 'Ectomorfo', // Morfologia
    'finalRating': 1, // Avaliação final
    'freeText': '', // Texto livre
  };

  // Função para submeter o relatório
  Future<void> submitReport() async {
    // Mostra um diálogo de confirmação antes de submeter
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
                    onPressed: () => Navigator.of(context).pop(true), // Confirma
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
                    onPressed: () => Navigator.of(context).pop(false), // Cancela
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
      return; // Cancela submissão se o usuário selecionar "Não"
    }

    setState(() {
      isLoading = true; // Mostra o indicador de carregamento
    });

    final token = await AuthService().getToken(); // Busca o token do usuário
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      // Mostra mensagem de erro se não encontrar o token
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Token não encontrado. Faça login novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final idUtilizador = JwtDecoder.getUserIdFromToken(token); // Extrai o ID do utilizador do token
      final Map<String, dynamic> dataToSend = {
        ...formData, // Copia os dados do formulário
        'idUser': idUtilizador, // Adiciona o ID do utilizador aos dados
      };

      // Faz o POST para criar o relatório
      final response = await http.post(
        Uri.parse('$apiUrl/reports/${widget.idAthlete}'), // Endpoint da API
        headers: {
          'Authorization': 'Bearer $token', // Token JWT no header
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dataToSend), // Dados em JSON
      );

      if (response.statusCode == 201) {
        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Relatorio criado com sucesso!'),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context); // Volta para a tela anterior
      } else {
        // Mostra mensagem de erro retornada pela API
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
      // Mostra mensagem de erro inesperado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Esconde o indicador de carregamento
      });
    }
  }

  // Incrementa o valor de um campo (até o máximo de 4)
  void incrementField(String field) {
    setState(() {
      if (formData[field] < 4) formData[field] += 1;
    });
  }

  // Decrementa o valor de um campo (até o mínimo de 1)
  void decrementField(String field) {
    setState(() {
      if (formData[field] > 1) {
        formData[field] -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Monta a interface da página
    return Scaffold(
      backgroundColor: const Color(0xFF262626), // Cor de fundo
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030), // Cor da AppBar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(), // Volta para a tela anterior
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
                // Campos do formulário (dropdowns e texto)
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
                const SizedBox(height: 18),
                // Botão para submeter o relatório
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
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
            // Mostra indicador de carregamento enquanto submete
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
                  Navigator.pop(context); // Volta para a tela anterior
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

// --- NOVOS WIDGETS DE ESTILO ---

  // Widget para criar um campo dropdown estilizado
  Widget _buildDropdownField(String label, String field, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // Nome do campo
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
            value: formData[field]?.toString(), // Valor selecionado
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
                formData[field] = value!; // Atualiza o valor selecionado
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

  // Widget para criar um campo de texto estilizado
  Widget _buildTextField(String label, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // Nome do campo
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
                formData[field] = value; // Atualiza o valor do campo de texto
              });
            },
          ),
        ),
      ],
    );
  }
}