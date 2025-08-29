import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../autenticacao/auth_service.dart';
import 'playerdetailspage_olheiro.dart';

class JogadoresOlheiroPage extends StatefulWidget {
  const JogadoresOlheiroPage({super.key});

  @override
  State<JogadoresOlheiroPage> createState() => _JogadoresOlheiroPageState();
}

class _JogadoresOlheiroPageState extends State<JogadoresOlheiroPage> {
  List<dynamic> atletas = [];
  List<dynamic> filteredAtletas = [];
  List<dynamic> posicoes = [];
  bool isLoading = false;
  String searchQuery = '';
  int currentPage = 1;
  final int itemsPerPage = 5;

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
          backgroundColor: const Color(0xFF232323),
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
                          size: 32, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Posição',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ...posicoes.map<Widget>((pos) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _filtrarPorPosicao(pos['name']);
                      },
                      child: Text(
                        pos['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _filtrarPorPosicao(null); // Limpa filtro
                    },
                    child: const Text(
                      'Limpar filtro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
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

  void _filtrarPorPosicao(String? nomePosicao) {
    setState(() {
      if (nomePosicao == null) {
        filteredAtletas = atletas;
      } else {
        filteredAtletas = atletas.where((a) {
          // Se a posição do atleta for um mapa, pega o nome
          String? posName;
          if (a['position'] is Map) {
            posName = a['position']['name'];
          } else if (a['position'] is String) {
            posName = a['position'];
          } else if (a['idPosition'] != null) {
            // Se só tens o id, tenta buscar o nome na lista de posições
            final pos = posicoes.firstWhere(
              (p) => p['id'].toString() == a['idPosition'].toString(),
              orElse: () => null,
            );
            posName = pos != null ? pos['name'] : null;
          }
          return posName == nomePosicao;
        }).toList();
      }
    });
  }

  void _avaliarAtleta(String idAthlete, int currentRating) {
    if (idAthlete == null || idAthlete == 'null' || idAthlete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do atleta inválido!')),
      );
      return;
    }
    int rating = currentRating;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF232323),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Avaliação',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Classificação: (1-5)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFD700),
                          size: 36,
                        ),
                        splashRadius: 22,
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão Cancelar
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFD9D9D9),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Botão Avaliar
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final token = await AuthService().getToken();
                            final config = {
                              'Authorization': 'Bearer $token',
                              'Content-Type': 'application/json',
                            };

                            try {
                              final response = await http.put(
                                Uri.parse(
                                    'https://pi4-3soq.onrender.com/athletes/$idAthlete'),
                                headers: config,
                                body: json.encode({'rating': rating}),
                              );

                              if (response.statusCode == 200) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Avaliação salva com sucesso!')),
                                  );
                                  setState(() {
                                    atletas = atletas.map((atleta) {
                                      if (atleta['idAthlete'] ==
                                          int.parse(idAthlete)) {
                                        atleta['rating'] = rating;
                                      }
                                      return atleta;
                                    }).toList();
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Erro ao salvar a avaliação.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Erro de rede.')),
                              );
                            }
                          },
                          child: const Text(
                            'Avaliar',
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _viewDetails(dynamic atleta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerOlheiroDetailsPage(
          atleta: atleta,
          onReportar: (id, rating) => _reportarAtleta(id, rating),
        ),
      ),
    );
  }

  void _reportarAtleta(String id, int rating) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reportar atleta: $id com avaliação $rating')),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Paginação
    final int totalPages = (filteredAtletas.length / itemsPerPage).ceil();
    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage) > filteredAtletas.length
        ? filteredAtletas.length
        : (startIndex + itemsPerPage);
    final List<dynamic> atletasPagina =
        filteredAtletas.sublist(startIndex, endIndex);

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
                        onChanged: (value) {
                          _searchAtletas(value);
                          setState(() {
                            currentPage =
                                1; // Volta sempre à primeira página ao pesquisar
                          });
                        },
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
                      itemCount: atletasPagina.length,
                      itemBuilder: (context, index) {
                        final atleta = atletasPagina[index];
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
                              _getPositionName(atleta['idPosition']),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                _viewDetails(atleta);
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
            // Paginação
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_left, color: Color(0xFFFFD700)),
                    onPressed: currentPage > 1
                        ? () {
                            setState(() {
                              currentPage--;
                            });
                          }
                        : null,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF303030),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$currentPage / $totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_right, color: Color(0xFFFFD700)),
                    onPressed: currentPage < totalPages
                        ? () {
                            setState(() {
                              currentPage++;
                            });
                          }
                        : null,
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

  String _getPositionName(dynamic idPosition) {
    if (idPosition == null) return '';
    final pos = posicoes.firstWhere(
      (p) => p['id'].toString() == idPosition.toString(),
      orElse: () => null,
    );
    return pos != null ? (pos['name'] ?? '') : '';
  }
}
