import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:http/http.dart' as http; // Importa o pacote http para requisições HTTP
import 'dart:convert'; // Importa para codificação/decodificação JSON
import '../autenticacao/auth_service.dart'; // Serviço de autenticação
import '../autenticacao/jwt_decode.dart'; // Utilitário para decodificar JWT
import 'jogos_page_olheiro.dart'; // Página de jogos por escalão

// Página de seleção de escalão para o olheiro
class EscalaoOlheiroPage extends StatefulWidget {
  const EscalaoOlheiroPage({super.key});

  @override
  State<EscalaoOlheiroPage> createState() => _EscalaoOlheiroPageState();
}

// Estado da página de seleção de escalão
class _EscalaoOlheiroPageState extends State<EscalaoOlheiroPage> {
  List<dynamic> categorias = []; // Lista de categorias etárias
  bool isLoadingCategorias = true; // Indica se está carregando categorias
  String? userRole; // Papel do utilizador autenticado
  String searchQuery = ''; // Texto da pesquisa
  List<dynamic> filteredCategorias = []; // Lista filtrada de categorias

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carrega dados do utilizador ao iniciar
  }

  // Carrega dados do utilizador autenticado e categorias
  Future<void> _loadUserData() async {
    try {
      final token = await AuthService().getToken(); // Obtém token
      if (token == null) {
        return;
      }

      // Decodificar o token para obter a role do utilizador
      final role = JwtDecoder.getUserRoleFromToken(token);
      setState(() {
        userRole = role;
      });

      _loadCategorias(); // Carrega categorias
      // ignore: empty_catches
    } catch (e) {}
  }

  // Filtra categorias pelo texto pesquisado
  void _searchCategorias(String query) {
    setState(() {
      searchQuery = query;
      filteredCategorias = categorias.where((categoria) {
        final nome = (categoria['name'] ?? '').toLowerCase();
        return nome.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Função para buscar as categorias etárias da API
  Future<void> _loadCategorias() async {
    final token = await AuthService().getToken(); // Obtém token
    final config = {'Authorization': 'Bearer $token'}; // Header de autorização

    try {
      final response = await http.get(
        Uri.parse('https://pi4-3soq.onrender.com/ageCategories'),
        headers: config,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body); // Decodifica JSON
        setState(() {
          categorias = data; // Guarda categorias
          isLoadingCategorias = false; // Esconde loader
        });
      } else {
        setState(() {
          isLoadingCategorias = false; // Esconde loader em caso de erro
        });
        // ignore: avoid_print
        print('Erro ao carregar as categorias: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingCategorias = false; // Esconde loader em caso de erro
      });
      // ignore: avoid_print
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estrutura visual da página
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Cor de fundo
      body: SafeArea(
        child: Column(
          children: [
            // Título centralizado
            Container(
              color: const Color(0xFF303030),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Jogos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Campo de pesquisa
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _searchCategorias(value); // Filtra categorias ao digitar
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lista de escalões ou mensagem de erro
            Expanded(
              child: isLoadingCategorias
                  ? const Center(child: CircularProgressIndicator()) // Loader
                  : categorias.isEmpty
                      ? const Center(
                          child: Text(
                            'Não existem escalões disponíveis.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: (searchQuery.isEmpty
                              ? categorias.length
                              : filteredCategorias.length),
                          itemBuilder: (context, index) {
                            final lista = searchQuery.isEmpty
                                ? categorias
                                : filteredCategorias;
                            final categoria = lista[index]['name']; // Nome do escalão
                            final idCategoriaEtaria =
                                lista[index]['idAgeCategory']; // ID do escalão

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Card(
                                color: const Color(0xFF2C2C2C),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  title: Text(
                                    categoria,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onTap: () {
                                    // Ao clicar, navega para a página de jogos desse escalão
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JogosOlheiroPage(
                                          idAgeCategory: idCategoriaEtaria,
                                          categoriaNome: categoria,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Botão home fixo no fundo
            Container(
              color: const Color(0xFF2C2C2C),
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: IconButton(
                icon:
                    const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst); // Volta ao início
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}