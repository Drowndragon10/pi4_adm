import 'package:flutter/material.dart';
import 'package:pi4/loginpage.dart';
import 'admin/players.dart';
import 'admin/add_jogador_page.dart';
import 'selecao_escalao_page.dart';
import 'admin/add_jogos_page.dart';
import 'admin/add_tarefa_page.dart';
import 'definicoes.dart';

// Função principal que inicia a aplicação Flutter
void main() {
  runApp(const MyApp());
}

// Widget principal da aplicação
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define o tema global e a página inicial (LoginPage)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viriatos Scouting',
      theme: ThemeData(
        fontFamily: 'fs-lucas-pro', // Fonte padrão
        brightness: Brightness.dark, // Tema escuro
        scaffoldBackgroundColor: Colors.black87, // Fundo do Scaffold
        primaryColor: Colors.blueGrey, // Cor principal
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey[900], // Fundo da barra inferior
          selectedItemColor: Colors.white, // Item selecionado
          unselectedItemColor: Colors.grey[400], // Item não selecionado
        ),
      ),
      home: const LoginPage(), // Página inicial
    );
  }
}

// Página principal do dashboard após login
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de opções principais do menu
    final List<_MenuOption> mainOptions = [
      _MenuOption(
        'Jogadores',
        Icons.sports_soccer,
        () {
          // Navega para a página de jogadores
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JogadoresPage()),
          );
        },
      ),
      _MenuOption('Jogos', Icons.sports, () {
        // Navega para a página de seleção de escalão
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EscalaoPage()),
        );
      }),
    ];
    // Lista de opções para adicionar entidades
    final List<_MenuOption> addOptions = [
      _MenuOption('Adicionar Jogador', Icons.sports_soccer_outlined, () {
        // Navega para a página de adicionar jogador
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAtletaPage()),
        );
      }),
      _MenuOption('Adicionar Jogo', Icons.sports_outlined, () {
        // Navega para a página de adicionar jogo
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddJogoPage()),
        );
      }),
      _MenuOption('Atribuir Tarefa', Icons.description_outlined, () {
        // Navega para a página de atribuir tarefa
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTarefaPage()),
        );
      }),
    ];
    // Opção de definições
    final _MenuOption settingsOption =
        _MenuOption('Definições', Icons.settings, () {
          // Navega para a página de definições
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DefinicoesPage()),
          );
        });

    // Função para construir cada botão do menu
    Widget buildButton(_MenuOption option) {
      return Material(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        elevation: 8,
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: option.onTap, // Ação ao clicar
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Icon(option.icon, color: const Color(0xFFFFD700), size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option.title,
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
      backgroundColor: const Color(0xFF232323),
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
              // Botões principais
              ...mainOptions.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: buildButton(option),
                  )),
              const SizedBox(height: 32),
              // Botões de adicionar
              ...addOptions.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: buildButton(option),
                  )),
              const Spacer(),
              // Botão de definições no fundo
              buildButton(settingsOption),
            ],
          ),
        ),
      ),
    );
  }
}

// Classe auxiliar para definir cada opção do menu
class _MenuOption {
  final String title; // Título do botão
  final IconData icon; // Ícone do botão
  final VoidCallback onTap; // Função ao clicar

  _MenuOption(this.title, this.icon, this.onTap);
}