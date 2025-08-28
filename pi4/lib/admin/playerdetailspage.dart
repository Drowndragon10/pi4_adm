import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class PlayerDetailsPage extends StatefulWidget {
  final dynamic atleta;
  final void Function(String idAtleta, int currentRating) onAvaliar;

  const PlayerDetailsPage({
    Key? key,
    required this.atleta,
    required this.onAvaliar,
  }) : super(key: key);

  @override
  State<PlayerDetailsPage> createState() => _PlayerDetailsPageState();
}

class _PlayerDetailsPageState extends State<PlayerDetailsPage> {
  late int rating;

  @override
  void initState() {
    super.initState();
    rating = widget.atleta['classificacao'] ?? widget.atleta['rating'] ?? 0;
  }

  void _atualizarRating(int novoRating) {
    setState(() {
      rating = novoRating;
    });
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (Platform.isAndroid) {
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
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Não foi possível abrir o link: $url';
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao abrir a URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            // Avatar e nome
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
                      Text(
                        widget.atleta['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        widget.atleta['birthdate'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      // Rating
                      const Text(
                        'Rating:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            _buildDetailRow('Posição:', widget.atleta['position']?['name'] ?? "N/A"),
            _buildDetailRow('Clube:', widget.atleta['team']?['name'] ?? "N/A"),
            _buildDetailRow(
                'Nacionalidade:', widget.atleta['nationality'] ?? "N/A"),
            _buildDetailRow(
                'Naturalidade:', widget.atleta['birthplace'] ?? "N/A"),
            _buildDetailRow('Encarregado:', widget.atleta['guardian']?['name'] ?? "N/A"),
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
            // Botão Avaliar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.onAvaliar(
                    widget.atleta['idAthlete']?.toString() ?? '',
                    rating,
                  );
                  // Após avaliar, atualize o rating local
                  if (mounted) {
                    setState(() {
                      rating = rating;
                    });
                  }
                },
                child: const Text(
                  'Avaliar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
