import 'package:flutter/material.dart';
import 'package:pi4/loginpage.dart';
import 'admin/players.dart';
import 'admin/add_jogador_page.dart';
import 'selecao_escalao_page.dart';
import 'admin/add_jogos_page.dart';
import 'admin/add_tarefa_page.dart';
import 'definicoes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viriatos Scouting',
      theme: ThemeData(
        fontFamily: 'Sora', // Define a fonte padrão globalmente
        brightness: Brightness.dark, // Mantém o tema escuro
        scaffoldBackgroundColor: Colors.black87, // Fundo do Scaffold
        primaryColor: Colors.blueGrey, // Cor do AppBar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey[900], // Fundo da BottomNavigationBar
          selectedItemColor: Colors.white, // Cor do item selecionado
          unselectedItemColor: Colors.grey[400], // Cor do item não selecionado
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Grupos de opções
    final List<_MenuOption> mainOptions = [
      _MenuOption(
        'Jogadores',
        Icons.sports_soccer,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JogadoresPage()),
          );
        },
      ),
      _MenuOption('Jogos', Icons.sports, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EscalaoPage()),
        );
      }),
    ];
    final List<_MenuOption> addOptions = [
      _MenuOption('Adicionar Jogador', Icons.sports_soccer_outlined, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAtletaPage()),
        );
      }),
      _MenuOption('Adicionar Jogo', Icons.sports_outlined, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddJogoPage()),
        );
      }),
      _MenuOption('Atribuir Tarefa', Icons.description_outlined, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTarefaPage()),
        );
      }),
    ];
    final _MenuOption settingsOption =
        _MenuOption('Definições', Icons.settings, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DefinicoesPage()),
          );
        });

    Widget buildButton(_MenuOption option) {
      return Material(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        elevation: 8,
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: option.onTap,
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

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
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
              // Grupo principal
              ...mainOptions.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: buildButton(option),
                  )),
              const SizedBox(height: 32),
              // Grupo adicionar
              ...addOptions.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: buildButton(option),
                  )),
              const Spacer(),
              // Definições no fundo
              buildButton(settingsOption),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _MenuOption(this.title, this.icon, this.onTap);
}
