import 'package:flutter/material.dart'; //interface visual
import 'selecao_escalao_page_treinador.dart'; //página dos escalões/jogos
import '../definicoes.dart'; //página das definições
import 'players_treinador.dart'; //página dos jogadores
import 'equipas_page.dart'; //página das equipas



class Treinador extends StatelessWidget { //não guarda estados, só mostra botões
  const Treinador({super.key});

  @override
  Widget build(BuildContext context) {
    // Grupos de opções
    final List<_MenuOption> mainOptions = [ //guarda principais opções do menu
      _MenuOption(
        'Jogadores',
        Icons.sports_soccer,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JogadoresTreinadorPage()),
          );
        },
      ),
      _MenuOption('Equipas', Icons.group, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EquipasPage()),
        );
      }),
      _MenuOption('Jogos', Icons.sports, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EscalaoTreinadorPage()),
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

    Widget buildButton(_MenuOption option) { //Cria um botão por cima
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
              const SizedBox(height: 270),
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
