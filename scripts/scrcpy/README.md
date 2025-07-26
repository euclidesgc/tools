# Scrcpy Manager

Este documento serve como um guia para o uso do script `sms.sh`, que tem como objetivo facilitar a conexão e o gerenciamento de dispositivos Android via scrcpy e adb.

## Uso

Para usar o script, execute `sms.sh` no seu terminal.

```bash
./sms.sh
```

Navegue pelos menus usando os números correspondentes a cada opção. Certifique-se de que o script tenha permissão de execução:

```bash
chmod +x sms.sh
```

## Dependências

O script `sms.sh` depende das seguintes ferramentas:
- **scrcpy**: Para espelhamento e controle do dispositivo Android.
- **adb (Android Debug Bridge)**: Para comunicação com o dispositivo Android.
- **Homebrew**: Para gerenciamento de pacotes no macOS (usado para instalar dependências).

## Funcionalidades

- **Conexão Rápida**: Conecta a dispositivos Android via USB ou WiFi com facilidade.
- **Diagnóstico e Solução de Problemas**: Ferramentas integradas para diagnosticar e resolver problemas de conexão.
- **Gerenciamento do Dispositivo**: Comandos para listar, conectar, desconectar e resetar dispositivos.
- **Configuração Flexível**: Ampla gama de configurações para personalizar a experiência com o scrcpy.
- **Logs Detalhados**: Gera logs detalhados das operações realizadas para depuração.

## 🌳 Estrutura do Menu

```
Menú Principal
├── 1. 🔗 Conectar Dispositivo
│   ├── 1. Conectar via WiFi (Padrão)
│   ├── 2. Conectar via WiFi (Baixa qualidade)
│   ├── 3. Conectar via WiFi (Alta qualidade)
│   ├── 4. Conectar via WiFi (Personalizada)
│   ├── 5. Conectar via USB
│   └── 6. Soluções rápidas para WiFi
│
├── 2. 🔧 Diagnóstico e Troubleshooting
│   ├── 1. Diagnóstico completo do sistema
│   ├── 2. Troubleshooting avançado
│   ├── 3. Testar conectividade WiFi
│   └── 4. Ver logs de erro detalhados
│
├── 3. 📱 Gerenciar Dispositivos
│   ├── 1. Listar todos os dispositivos
│   ├── 2. Desconectar dispositivos WiFi
│   ├── 3. Reconectar dispositivo WiFi
│   └── 4. Resetar conexões ADB
│
├── 4. ⚙️  Configurações
│   ├── 1. Ativar/Desativar logs de debug
│   ├── 2. Configurar opções do scrcpy
│   │   ├── 1. 🎮 Controles
│   │   │   ├── Ativar/Desativar 'show-touches'
│   │   │   ├── Ativar/Desativar 'no-control'
│   │   │   └── Ativar/Desativar 'stay-awake'
│   │   ├── 2. 🎥 Vídeo
│   │   │   ├── Definir 'max-size'
│   │   │   ├── Definir 'max-fps'
│   │   │   ├── Definir 'video-bit-rate'
│   │   │   ├── Definir 'video-codec'
│   │   │   ├── Definir 'crop'
│   │   │   └── Definir 'display-orientation'
│   │   ├── 3. 🔊 Áudio
│   │   │   ├── Definir 'audio-bit-rate'
│   │   │   ├── Definir 'audio-codec'
│   │   │   ├── Definir 'audio-source'
│   │   │   └── Ativar/Desativar 'no-audio'
│   │   ├── 4. 🪟 Janela
│   │   │   ├── Definir 'window-title'
│   │   │   ├── Ativar/Desativar 'window-borderless'
│   │   │   ├── Ativar/Desativar 'always-on-top'
│   │   │   └── Ativar/Desativar 'fullscreen'
│   │   └── 5. 🔧 Avançado
│   │       ├── Ativar/Desativar 'turn-screen-off'
│   │       ├── Ativar/Desativar 'power-off-on-close'
│   │       ├── Ativar/Desativar 'print-fps'
│   │       ├── Ativar/Desativar 'no-clipboard-autosync'
│   │       ├── Ativar/Desativar 'disable-screensaver'
│   │       └── Definir 'verbosity'
│   ├── 3. Ver configurações atuais
│   ├── 4. Configurar timeout de conexão
│   ├── 5. Verificar/Instalar dependências
│   ├── 6. Resetar configurações para padrão
│   └── 7. Mostrar informações do sistema
│
└── 0. 🚪 Sair
```

## Detalhes das Funcionalidades

### 1. 🔗 Conectar Dispositivo
- **Conexão WiFi**: Oferece perfis de conexão (Padrão, Baixa e Alta qualidade) e uma opção personalizada para ajustar os parâmetros do `scrcpy`.
- **Conexão USB**: Conecta ao dispositivo via cabo USB.
- **Soluções Rápidas para WiFi**: Ajuda a resolver problemas comuns de conexão WiFi, como reiniciar a porta `adb`.

### 2. 🔧 Diagnóstico e Troubleshooting
- **Diagnóstico Completo**: Verifica o status do `adb`, `scrcpy`, e a conectividade do dispositivo.
- **Troubleshooting Avançado**: Oferece um guia passo a passo para resolver problemas mais complexos.
- **Teste de Conectividade**: Realiza um `ping` no dispositivo para verificar a conexão de rede.
- **Logs de Erro**: Permite visualizar os logs de erro detalhados para uma análise aprofundada.

### 3. 📱 Gerenciar Dispositivos
- **Listar Dispositivos**: Mostra todos os dispositivos conectados via `adb`.
- **Desconectar/Reconectar**: Gerencia as conexões WiFi dos dispositivos.
- **Resetar ADB**: Reinicia o servidor `adb` para resolver problemas de conexão.

### 4. ⚙️ Configurações
- **Logs de Debug**: Ativa ou desativa a geração de logs detalhados para depuração.
- **Configurar scrcpy**: Permite um ajuste fino de todas as opções do `scrcpy`, divididas em categorias:
    - **Controles**: `show-touches`, `no-control`, `stay-awake`.
    - **Vídeo**: `max-size`, `max-fps`, `video-bit-rate`, `video-codec`, `crop`, `display-orientation`.
    - **Áudio**: `audio-bit-rate`, `audio-codec`, `audio-source`, `no-audio`.
    - **Janela**: `window-title`, `window-borderless`, `always-on-top`, `fullscreen`.
    - **Avançado**: `turn-screen-off`, `power-off-on-close`, `print-fps`, `no-clipboard-autosync`, `disable-screensaver`, `verbosity`.
- **Ver Configurações Atuais**: Exibe os parâmetros do `scrcpy` que serão usados na próxima conexão.
- **Timeout de Conexão**: Ajusta o tempo de espera para a conexão WiFi.
- **Dependências**: Verifica se `scrcpy`, `adb` e `Homebrew` estão instalados e, se necessário, os instala.
- **Resetar Configurações**: Restaura todas as opções do `scrcpy` para os valores padrão.
- **Informações do Sistema**: Exibe detalhes sobre o sistema operacional e as versões das dependências.

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir uma issue ou enviar um pull request.

## Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).