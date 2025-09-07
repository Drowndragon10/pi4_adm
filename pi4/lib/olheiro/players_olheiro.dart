import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:http/http.dart' as http; // Importa o pacote http para requisições HTTP
import 'dart:convert'; // Importa para codificação/decodificação JSON
import '../autenticacao/auth_service.dart'; // Serviço de autenticação
import 'playerdetailspage_olheiro.dart'; // Página de detalhes do jogador

// Página de lista de jogadores para o olheiro
class JogadoresOlheiroPage extends StatefulWidget {
  const JogadoresOlheiroPage({super.key});

  @override
  State<JogadoresOlheiroPage> createState() => _JogadoresOlheiroPageState();
}

// Estado da página de jogadores
class _JogadoresOlheiroPageState extends State<JogadoresOlheiroPage> {
  List<dynamic> atletas = []; // Lista de todos os atletas
  List<dynamic> filteredAtletas = []; // Lista filtrada de atletas
  List<dynamic> posicoes = []; // Lista de posições disponíveis
  bool isLoading = false; // Indica se está carregando dados
  String searchQuery = ''; // Texto da pesquisa
  int currentPage = 1; // Página atual da paginação
  final int itemsPerPage = 5; // Número de itens por página

  @override
  void initState() {
    super.initState();
    _loadAtletas(); // Carrega atletas ao iniciar
    _loadFilters(); // Carrega filtros (posições)
  }

  // Carrega a lista de atletas da API
  Future<void> _loadAtletas() async {
    setState(() {
      isLoading = true; // Mostra loader
    });

    final token = await AuthService().getToken(); // Obtém token do utilizador
    final config = {'Authorization': 'Bearer $token'}; // Header de autorização

    final response = await http.get(
      Uri.parse('https://pi4-3soq.onrender.com/athletes'),
      headers: config,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decodifica JSON
      if (mounted) {
        setState(() {
          atletas = data; // Guarda atletas
          filteredAtletas = data; // Inicializa lista filtrada
          isLoading = false; // Esconde loader
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false; // Esconde loader em caso de erro
        });
      }
    }
  }

  // Carrega as posições disponíveis da API
  Future<void> _loadFilters() async {
    final token = await AuthService().getToken();
    final config = {'Authorization': 'Bearer $token'};
    final posicoesResponse = await http.get(
      Uri.parse('https://pi4-3soq.onrender.com/positions'),
      headers: config,
    );
    if (posicoesResponse.statusCode == 200) {
      setState(() {
        posicoes = json.decode(posicoesResponse.body); // Guarda posições
      });
    }
  }

  // Filtra atletas pelo texto pesquisado
  void _searchAtletas(String query) {
    setState(() {
      searchQuery = query;
      filteredAtletas = atletas.where((atleta) {
        final nome = (atleta['name'] ?? '').toLowerCase();
        return nome.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Mostra o dialog para filtrar por posição
  void _showFiltroPosicaoDialog() async {
    // Garante que as posições estão carregadas
    if (posicoes.isEmpty) {
      await _loadFilters();
    }
    showDialog(
      // ignore: use_build_context_synchronously
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
                      onTap: () => Navigator.pop(context), // Fecha o dialog
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
                // Lista de botões para cada posição
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
                        _filtrarPorPosicao(pos['name']); // Filtra por posição
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
                }),
                const SizedBox(height: 8),
                // Botão para limpar filtro
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

  // Filtra atletas pela posição selecionada
  void _filtrarPorPosicao(String? nomePosicao) {
    setState(() {
      if (nomePosicao == null) {
        filteredAtletas = atletas; // Sem filtro
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

  // Abre a página de detalhes do atleta
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

  // Função de callback para reportar atleta (exemplo)
  void _reportarAtleta(String id, int rating) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reportar atleta: $id com avaliação $rating')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Paginação
    final int totalPages = (filteredAtletas.length / itemsPerPage).ceil(); // Total de páginas
    final int startIndex = (currentPage - 1) * itemsPerPage; // Índice inicial
    final int endIndex = (startIndex + itemsPerPage) > filteredAtletas.length
        ? filteredAtletas.length
        : (startIndex + itemsPerPage); // Índice final
    final List<dynamic> atletasPagina =
        filteredAtletas.sublist(startIndex, endIndex); // Lista da página atual

    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Cor de fundo
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
                    onPressed: _showFiltroPosicaoDialog, // Abre filtro de posição
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
                          _searchAtletas(value); // Pesquisa atletas
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
                  ? const Center(child: CircularProgressIndicator()) // Loader
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
                                // ignore: deprecated_member_use
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
                              _getPositionName(atleta['idPosition']), // Mostra posição
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                _viewDetails(atleta); // Vai para detalhes
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
                      '$currentPage / $totalPages', // Mostra página atual/total
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

  // Retorna o nome da posição pelo id
  String _getPositionName(dynamic idPosition) {
    if (idPosition == null) return '';
    final pos = posicoes.firstWhere(
      (p) => p['id'].toString() == idPosition.toString(),
      orElse: () => null,
    );
    return pos != null ? (pos['name'] ?? '') : '';
  }
}