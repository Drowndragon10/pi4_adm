import 'package:flutter/material.dart';

class TermosPage extends StatelessWidget {
  const TermosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                Navigator.pop(context);
              },
              splashRadius: 28,
            ),
          ),
        ),
        title: const Text(
          "Termos e Condições",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "1. Identificação do responsável pelo tratamento",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Académico de Viseu Futebol Clube\n"
            "NIPC 503954306\n"
            "Sede: Estádio Municipal do Fontelo, Avenida Anacleto Pinto, freguesia e concelho de Viseu.\n"
            "Contato do EPD (Encarregado da Proteção de Dados): xxxxx@xxxxx",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text(
            "2. Informação, consentimento e finalidade do tratamento",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "A Lei da Proteção de Dados Pessoais (em diante “LPD”) e o Regulamento Geral de Proteção de Dados "
            "(Regulamento (UE) 2016/679 do Parlamento Europeu e do Conselho de 27 de abril de 2016, em diante “RGPD”) "
            "e a Lei 58/2019, de 8 de agosto, asseguram a proteção das pessoas singulares no que diz respeito ao tratamento "
            "de dados pessoais e à livre circulação desses dados.",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text(
            "3. Medidas de segurança",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "O Académico de Viseu Futebol Clube declara que implementou e continuará a implementar as medidas de segurança de "
            "natureza técnica e organizativa necessárias para garantir a segurança dos dados de carácter pessoal que lhe sejam "
            "fornecidos visando evitar a sua alteração, perda, tratamento e/ou acesso não autorizado.",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text(
            "4. Exercício dos direitos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "O titular dos dados pessoais/encarregados de educação podem, exercer a todo o tempo, os seus direitos de acesso, "
            "retificação, apagamento, limitação, oposição e portabilidade.",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text(
            "5. Prazo de conservação",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "O Académico de Viseu Futebol Clube apenas trata os dados pessoais durante o período que se revele necessário ao "
            "cumprimento da sua finalidade (criação de histórico do atleta desde a formação à profissionalização), sem prejuízo "
            "dos dados serem conservados por um período superior, por exigências legais.",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text(
            "6. Autoridade de controlo",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Nos termos legais, o titular dos dados tem o direito de apresentar uma reclamação em matéria de proteção de dados "
            "pessoais à autoridade de controlo competente, a Comissão Nacional de Proteção de Dados (CNPD).",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
