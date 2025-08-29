import 'package:flutter/material.dart';
import 'package:pi4/loginpage.dart';
import '../admin/players.dart';
import '../selecao_escalao_page.dart';
import 'relatorios_submetidos.dart';
import '../definicoes.dart';
import 'minhastarefas_page.dart';



class OlheiroPage extends StatelessWidget {
  const OlheiroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Grupos de opções
    final List<_MenuOption> mainOptions = [
      _MenuOption(
        'Tarefas',
        Icons.description_outlined,
        () {
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
              const SizedBox(height: 220),
              // Grupo adicionar
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
