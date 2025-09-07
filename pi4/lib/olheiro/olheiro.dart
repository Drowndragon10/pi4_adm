import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'selecao_escalao_page_olheiro.dart'; // Página de seleção de escalão
import 'relatorios_submetidos.dart'; // Página de relatórios submetidos
import '../definicoes.dart'; // Página de definições
import 'minhastarefas_page.dart'; // Página das tarefas do olheiro
import 'players_olheiro.dart'; // Página de jogadores

// Página principal do olheiro (menu)
class OlheiroPage extends StatelessWidget {
  const OlheiroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de opções principais do menu
    final List<_MenuOption> mainOptions = [
      _MenuOption(
        'Tarefas', // Título do botão
        Icons.description_outlined, // Ícone do botão
        () {
          // Ação ao clicar: navega para a página de tarefas
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MinhasTarefasPage()),
          );
        },
      ),
      _MenuOption(
        'Relatórios',
        Icons.edit,
        () {
          // Ação ao clicar: navega para a página de relatórios submetidos
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RelatoriosSubmetidosPage()),
          );
        },
      ),
      _MenuOption(
        'Jogadores',
        Icons.sports_soccer,
        () {
          // Ação ao clicar: navega para a página de jogadores
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JogadoresOlheiroPage()),
          );
        },
      ),
      _MenuOption('Jogos', Icons.sports, () {
        // Ação ao clicar: navega para a página de seleção de escalão
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EscalaoOlheiroPage()),
        );
      }),
    ];
    
    // Opção de definições (fica no fundo)
    final _MenuOption settingsOption =
        _MenuOption('Definições', Icons.settings, () {
          // Ação ao clicar: navega para a página de definições
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DefinicoesPage()),
          );
        });

    // Função para construir um botão de menu estilizado
    Widget buildButton(_MenuOption option) {
      return Material(
        color: const Color(0xFF2C2C2C), // Cor de fundo do botão
        borderRadius: BorderRadius.circular(12), // Bordas arredondadas
        elevation: 8, // Sombra
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.5), // Cor da sombra
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: option.onTap, // Ação ao clicar
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Icon(option.icon, color: const Color(0xFFFFD700), size: 30), // Ícone
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option.title, // Título do botão
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Estrutura visual da página
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Cor de fundo da página
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Título de boas-vindas
              const Center(
                child: Text(
                  'Bem-vindo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Botões principais do menu
              ...mainOptions.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: buildButton(option),
                  )),
              const SizedBox(height: 220),
              // Botão de definições no fundo
              buildButton(settingsOption),
            ],
          ),
        ),
      ),
    );
  }
}

// Classe para representar uma opção do menu
class _MenuOption {
  final String title; // Título da opção
  final IconData icon; // Ícone da opção
  final VoidCallback onTap; // Função a executar ao clicar

  _MenuOption(this.title, this.icon, this.onTap);
}