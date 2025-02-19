import 'package:flutter/material.dart'; // Importa a biblioteca de widgets do Flutter
import 'package:med_agenda/models/user_model.dart'; // Importa o modelo de dados de usuário
import 'package:med_agenda/services/user_service.dart'; // Importa o serviço responsável por acessar os dados do usuário
import 'package:provider/provider.dart'; // Importa a biblioteca provider para gerenciar o estado

// Classe que representa a visualização da lista de pacientes
class PatientListView extends StatelessWidget {
  const PatientListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utiliza o StreamBuilder para construir a interface com base nos dados em tempo real
    return StreamBuilder<List<UserModel>>(
      // Obtém a lista de pacientes a partir do serviço UserService
      stream: context.read<UserService>().getPatients(),
      builder: (context, snapshot) {
        // Verifica se o stream está aguardando dados, exibe um indicador de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Verifica se ocorreu algum erro ao tentar carregar os dados
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        // Caso não haja erro, pega a lista de pacientes ou um array vazio se não houver dados
        final patients = snapshot.data ?? [];

        // Constrói a lista de pacientes com ListView.builder
        return ListView.builder(
          padding: const EdgeInsets.all(16.0), // Adiciona um padding ao redor da lista
          itemCount: patients.length, // Define o número de itens a serem exibidos (quantidade de pacientes)
          itemBuilder: (context, index) {
            // Obtém o paciente na posição 'index'
            final patient = patients[index];
            return Card( // Cada paciente será exibido dentro de um Card
              child: ListTile(
                leading: const CircleAvatar( // Exibe um avatar circular no início da linha
                  child: Icon(Icons.person), // Ícone de pessoa no avatar
                ),
                title: Text(patient.name), // Nome do paciente como título
                subtitle: Text(patient.email), // E-mail do paciente como subtítulo
              ),
            );
          },
        );
      },
    );
  }
}
