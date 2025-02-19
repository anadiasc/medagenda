# MedAgenda

MedAgenda é um aplicativo desenvolvido em Flutter para gerenciar agendamentos médicos de forma prática e eficiente. O aplicativo usa o padrão de arquitetura **MVVM** (Model-View-ViewModel) e integra-se ao **Firebase** para autenticação e armazenamento de dados.

## Arquitetura do Projeto

Este projeto segue a arquitetura **MVVM (Model-View-ViewModel)**. A arquitetura MVVM é uma separação clara entre a lógica de negócios (Model), a interface do usuário (View) e a lógica de apresentação (ViewModel). Isso torna o código mais modular, fácil de testar e manter.

- **Model**: Representa os dados e serviços do aplicativo, como `AuthService`, `UserService` e `AppointmentService`, que fazem a comunicação com o Firebase ou outras fontes de dados.
  
- **View**: As interfaces de usuário, que são as telas ou páginas do aplicativo, como `HomeView`, `LoginView` e `SplashView`.

- **ViewModel**: A camada que faz a ponte entre o Model e a View, manipulando a lógica de apresentação e gerenciando os dados que a View irá exibir. No caso do MedAgenda, o `AppointmentViewModel` é um exemplo de ViewModel.

## Instalação

### Pré-requisitos

- Flutter 3.0 ou superior
- Conta no Firebase (para configurar o Firebase Auth e Firestore)
- Android Studio ou VSCode (com suporte ao Flutter)
  
### Configuração

#### Passo 1: Clonar o repositório


## Configuração do Projeto

1. **Pré-requisitos**
   - Flutter SDK
   - Dart SDK
   - Firebase account

2. **Configuração do Firebase**
   - Crie um novo projeto no [Firebase Console](https://console.firebase.google.com/)
   - Ative Authentication (Email/Password e Google Sign-in)
   - Crie um novo Cloud Firestore database
   - Baixe o arquivo de configuração `google-services.json` e adicione-o ao diretório `android/app/`
   - Atualize as configurações do Firebase em `lib/main.dart` com suas credenciais

3. **Instalação das Dependências**
   ```bash
   flutter pub get
   ```

4. **Executando o Projeto**
   ```bash
   flutter run
   ```

## Estrutura do Projeto

```
lib/
  lib/
   ├── models/               # Classes de modelo (UserModel, AppointmentModel)
   ├── services/             # Serviços (AuthService, AppointmentService, UserService)
   ├── viewmodels/           # ViewModels (AppointmentViewModel, AuthViewModel)
   ├── views/                # Telas do aplicativo (DoctorAppointmentsView, DoctorStatisticsView)
   │   ├── doctor_views/     # Telas específicas para médicos
   |   ├── home              # Telas inicial
   |   ├── login             # Telas de login
   |   ├── splash            # Telas de splash
   │   └── patient_views/    # Telas específicas para pacientes
   └── main.dart             # Ponto de entrada do aplicativo
```

## Tecnologias Utilizadas

- Flutter
- Firebase Authentication
- Cloud Firestore
- Provider (Gerenciamento de Estado)
- fl_chart (Gráficos)
- intl (Formatação de data/hora)

## Vídeo Explicativo


