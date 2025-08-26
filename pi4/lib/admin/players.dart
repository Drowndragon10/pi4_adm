import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';

class JogadoresPage extends StatefulWidget {
  const JogadoresPage({super.key});

  @override
  State<JogadoresPage> createState() => _JogadoresPageState();
}

class _JogadoresPageState extends State<JogadoresPage> {
  List<dynamic> atletas = [];
  List<dynamic> filteredAtletas = [];
  List<dynamic> posicoes = [];
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAtletas();
    _loadFilters();
  }

  Future<void> _loadAtletas() async {
    setState(() {
      isLoading = true;
    });

    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};

    final response = await http.get(
      Uri.parse('https://pi4-3soq.onrender.com/athletes'),
      headers: config,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          atletas = data;
          filteredAtletas = data;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFilters() async {
    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};
    final posicoesResponse = await http.get(
      Uri.parse('https://pi4-3soq.onrender.com/positions'),
      headers: config,
    );
    if (posicoesResponse.statusCode == 200) {
      setState(() {
        posicoes = json.decode(posicoesResponse.body);
      });
    }
  }

  void _searchAtletas(String query) {
    setState(() {
      searchQuery = query;
      filteredAtletas = atletas.where((atleta) {
        final nome = (atleta['name'] ?? '').toLowerCase();
        return nome.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showFiltroPosicaoDialog() async {
    // Garante que as posições estão carregadas
    if (posicoes.isEmpty) {
      await _loadFilters();
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFE5E5E5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          size: 32, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Posição',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...posicoes.map<Widget>((pos) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _filtrarPorPosicao(pos['name']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        pos['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _filtrarPorPosicao(null); // Limpa filtro
                  },
                  child: const Text('Limpar filtro'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _filtrarPorPosicao(String? posicao) {
    setState(() {
      if (posicao == null) {
        filteredAtletas = atletas;
      } else {
        filteredAtletas =
            atletas.where((a) => (a['position'] ?? '') == posicao).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Column(
          children: [
            // Título
            Container(
              width: double.infinity,
              color: const Color(0xFF2C2C2C),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Center(
                child: Text(
                  'Jogadores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Filtros e pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Botão Filtros (aqui só visual, podes abrir um modal se quiseres)
                  ElevatedButton(
                    onPressed: _showFiltroPosicaoDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                    ),
                    child: const Text(
                      'Filtros',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Campo pesquisa
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white70),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: _searchAtletas,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de jogadores
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredAtletas.length,
                      itemBuilder: (context, index) {
                        final atleta = filteredAtletas[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 28,
                              child: Icon(Icons.person,
                                  color: Colors.black, size: 32),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  (atleta['number'] ?? '1').toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  atleta['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              atleta['position'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                // Ver mais detalhes
                              },
                              child: const Text(
                                'Ver mais',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Paginação (exemplo visual, implementa a lógica conforme precisares)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF303030),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_right, color: Color(0xFFFFD700)),
                    onPressed: () {
                      // Próxima página
                    },
                  ),
                ],
              ),
            ),
            // Botão home
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
