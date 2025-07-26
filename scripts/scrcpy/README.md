# SCRCPY Manager (`scrcpymng.sh`)

Este script facilita a conexão, diagnóstico e gerenciamento de dispositivos Android via [scrcpy](https://github.com/Genymobile/scrcpy) e adb, com um menu interativo e colorido.

## Funcionalidades
- **Conectar dispositivo Android via WiFi ou USB**: Várias opções de qualidade de vídeo e performance.
- **Diagnóstico e troubleshooting**: Ferramentas para testar conectividade, logs detalhados e soluções rápidas para problemas comuns.
- **Gerenciar dispositivos**: Listar, desconectar, reconectar e resetar conexões ADB.
- **Configurações avançadas**: Personalize opções do scrcpy, ative/desative logs, configure qualidade padrão, etc.
- **Menu colorido e intuitivo**: Interface amigável, com emojis e destaques para facilitar a navegação.
- **Aviso automático sobre VPN**: Lembra o usuário de desconectar VPNs para evitar falhas de conexão.

## Como usar
1. Dê permissão de execução ao script:
   ```bash
   chmod +x scrcpymng.sh
   ```
2. Execute o script:
   ```bash
   ./scrcpymng.sh
   ```

## Requisitos
- [scrcpy](https://github.com/Genymobile/scrcpy)
- adb
- Bash 4+
- macOS ou Linux

## Recomendações
- Desconecte de VPNs antes de usar o script para evitar problemas de conexão.
- Use cabos USB de boa qualidade para conexões estáveis.

---

> Para dúvidas ou sugestões, consulte a documentação oficial do scrcpy ou abra uma issue neste repositório.
