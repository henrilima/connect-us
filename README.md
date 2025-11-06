# connect-us
Aplicativo simples para casais/namorados/parceiros. Este projeto tem como objetivo praticar o desenvolvimento mobile com flutter.

## Descrição
App pensado para fortalecer conexões entre pares.
Resumo rápido das funcionalidades principais — veja a seção [Funcionalidades](#funcionalidades) para a descrição completa.

## Status
Versão final — funcionalidades ainda poderão ser aprimoradas ou novas serão adicionadas.

## Funcionalidades
- Contador de tempo de relacionamento;
- Chat simples para mensagens (sem notificações);
- Contadores de abraços e beijos (sendo possível adicionar mais contadores);
- Distância entre usuários (compartilhamento de localização para cálculo de distância, requer permissão de localização);
- Linha do tempo para eventos importantes;
- Formulário de Linguagem do Amor para conhecer melhor o parceiro/parceira;
- Dedicação de músicas (com notas) utilizando links do Spotify.


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