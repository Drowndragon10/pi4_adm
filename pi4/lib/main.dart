import 'package:flutter/material.dart';
import 'package:pi4/loginpage.dart';

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
    // Lista de opções do menu
    final List<_MenuOption> options = [
      _MenuOption('Utilizadores', Icons.person, () {}),
      _MenuOption('Jogadores', Icons.sports_soccer, () {}),
      _MenuOption('Jogos', Icons.sports, () {}),
      _MenuOption('Tarefas', Icons.description, () {}),
      _MenuOption('Adicionar Jogador', Icons.sports_soccer_outlined, () {}),
      _MenuOption('Adicionar Jogo', Icons.sports_outlined, () {}),
      _MenuOption('Atribuir Tarefa', Icons.description_outlined, () {}),
      _MenuOption('Definições', Icons.settings, () {}),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return Material(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: option.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Row(
                            children: [
                              Icon(option.icon, color: Color(0xFFFFD700), size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
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