import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:url_launcher/url_launcher.dart'; // Importa para abrir links externos
import 'dart:io'; // Importa para verificar plataforma (Android/iOS)
import 'add_report_page.dart'; // Importa a página de criar relatório

// Página de detalhes do atleta para o olheiro
class PlayerOlheiroDetailsPage extends StatefulWidget {
  final dynamic atleta; // Dados do atleta
  final void Function(String idAthlete, int currentRating) onReportar; // Callback para reportar

  const PlayerOlheiroDetailsPage({
    Key? key,
    required this.atleta,
    required this.onReportar,
  }) : super(key: key);

  @override
  State<PlayerOlheiroDetailsPage> createState() => _PlayerOlheiroDetailsPageState();
}

// Estado da página de detalhes do atleta
class _PlayerOlheiroDetailsPageState extends State<PlayerOlheiroDetailsPage> {
  late int rating; // Rating do atleta

  @override
  void initState() {
    super.initState();
    // Inicializa o rating a partir dos dados do atleta
    rating = widget.atleta['classificacao'] ?? widget.atleta['rating'] ?? 0;
  }

  // Função para abrir um link externo (URL)
  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (Platform.isAndroid) {
        // Para Android, tenta abrir no Chrome
        final Uri chromeUri = Uri.parse(
            'intent://$url#Intent;scheme=https;package=com.android.chrome;end');

        if (await canLaunchUrl(chromeUri)) {
          await launchUrl(chromeUri, mode: LaunchMode.externalApplication);
        } else if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Não foi possível abrir o link: $url';
        }
      } else {
        // Para outras plataformas
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Não foi possível abrir o link: $url';
        }
      }
    } catch (e) {
      // Em caso de erro ao abrir o link
      print('Erro ao abrir a URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estrutura visual da página
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Cor de fundo
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323), // Cor da AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Botão voltar
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Perfil do Atleta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar e nome do atleta
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.black),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do atleta
                      Text(
                        widget.atleta['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      // Data de nascimento
                      Text(
                        widget.atleta['birthdate'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      // Label do rating
                      const Text(
                        'Rating:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Estrelas do rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < (widget.atleta['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Linha de detalhe: posição
            _buildDetailRow(
                'Posição:', widget.atleta['position']?['name'] ?? "N/A"),
            // Linha de detalhe: clube
            _buildDetailRow('Clube:', widget.atleta['team']?['name'] ?? "N/A"),
            // Linha de detalhe: nacionalidade
            _buildDetailRow(
                'Nacionalidade:', widget.atleta['nationality'] ?? "N/A"),
            // Linha de detalhe: naturalidade
            _buildDetailRow(
                'Naturalidade:', widget.atleta['birthplace'] ?? "N/A"),
            // Linha de detalhe: encarregado
            _buildDetailRow(
                'Encarregado:', widget.atleta['guardian']?['name'] ?? "N/A"),
            // Linha de detalhe: link
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Link:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(width: 5),
                Expanded(
                  child: InkWell(
                    child: Text(
                      widget.atleta['link'] ?? "N/A",
                      style: const TextStyle(
                        color: Colors.amber,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () {
                      if (widget.atleta['link'] != null &&
                          widget.atleta['link'].isNotEmpty) {
                        _launchUrl(widget.atleta['link']);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Botão para criar relatório
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.atleta['idAthlete'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CriarRelatorioPage(
                          idAthlete: widget.atleta['idAthlete'],
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Atleta não atribuído!'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                ),
                child: const Text(
                  'Criar Relatório',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Barra inferior fixa com botão Home
      bottomNavigationBar: Container(
        color: const Color(0xFF2C2C2C),
        child: IconButton(
          icon: const Icon(Icons.home, color: Color(0xFFFFD700), size: 36),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }

  // Widget auxiliar para mostrar uma linha de detalhe (label + valor)
  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}