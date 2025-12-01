# connect-us
Aplicativo simples para casais/namorados/parceiros. Este projeto tem como objetivo praticar o desenvolvimento mobile com flutter.

## Descrição
App pensado para fortalecer conexões entre pares.
Resumo rápido das funcionalidades principais — veja a seção [Funcionalidades](#funcionalidades) para a descrição completa.

## Status
Versão 2.0 — Atualização principal com novos recursos de interação e gamificação.

## Funcionalidades
- **Contador de tempo**: Visualize há quanto tempo estão juntos;
- **Chat**: Mensagens em tempo real para o casal;
- **Contadores**: Registre abraços, beijos e crie contadores personalizados;
- **Localização**: Veja a distância entre vocês (requer permissão);
- **Linha do Tempo**: Registre eventos importantes da história do casal;
- **Linguagem do Amor**: Descubra a linguagem do amor do seu parceiro(a);
- **Spotify**: Dedique músicas e compartilhe o que está ouvindo;
- **Surpresas**: Agende mensagens especiais para serem reveladas no futuro;
- **Fotos Diárias**: Compartilhe uma foto do seu dia (estilo BeReal);
- **Sentimentos**: Registre como está se sentindo e acompanhe o humor do parceiro;
- **Momentos**: Lista de desejos/tarefas para realizarem juntos;
- **Conquistas**: Desbloqueie conquistas conforme utilizam o app;
- **Pedra, Papel e Tesoura**: Joguinho rápido para tomar decisões.


## Como contribuir
Abra issues para discutir features/bugs e envie pull requests com pequenas mudanças.

## Requisitos

- Ambiente de desenvolvimento
  - Flutter SDK (canal stable) — versão estável mais recente.
  - Android SDK (com Android command-line tools e build-tools).
  - JDK 11+ para builds Android.

- Configurações de build
  - minSdkVersion Android recomendada: 21+ (ajustar conforme necessidade).

- Serviços externos
  - Conta Firebase e projeto configurado.
  - Firebase Realtime Database ativado e regras apropriadas.
  - Arquivos de configuração:
    - google-services.json (Android).
  - Credenciais da API do Spotify.

- Dispositivos de teste
  - Emuladores Android/iOS e/ou dispositivos físicos com GPS e acesso à Internet.

Observação: ajuste versões mínimas e plugins conforme necessidades do projeto.

## Nota
Não há sistema de notificações implementado no momento; foco inicial em recursos de registro, contagem e interação básica.

## Licença
[MIT](LICENSE)