# PURO Manager (`puromng.sh`)

Este script é um gerenciador interativo para ambientes Flutter utilizando o [Puro](https://puro.dev/). Ele facilita a instalação, atualização, remoção e seleção de versões do Flutter, além de gerenciar o próprio Puro, tudo por meio de um menu colorido e prático no terminal.

## Funcionalidades
- **Selecionar versão global do Flutter**: Defina qual versão do Flutter será usada globalmente no sistema.
- **Selecionar versão do Flutter para o projeto atual**: Permite definir uma versão específica do Flutter apenas para o projeto em que está rodando.
- **Remover versões do Flutter**: Lista apenas ambientes instalados e permite removê-los com segurança.
- **Atualizar o Puro**: Atualiza o gerenciador Puro para a versão mais recente.
- **Limpar caches**: Remove caches de versões não utilizadas do Flutter.
- **Instalar/Desinstalar o Puro**: Instala ou remove o Puro do sistema.
- **Menu colorido e intuitivo**: Interface amigável, com emojis e destaques para facilitar a navegação.

## Como usar
1. Dê permissão de execução ao script:
   ```bash
   chmod +x puromng.sh
   ```
2. Execute o script:
   ```bash
   ./puromng.sh
   ```

## Requisitos
- [Puro](https://puro.dev/) (o próprio script pode instalar)
- Bash 4+
- macOS ou Linux

## Recomendações
- Sempre abra um novo terminal após instalar ou atualizar o Puro para garantir que o PATH esteja atualizado.
- Para projetos Flutter, utilize a opção de definir a versão apenas para o projeto para evitar conflitos entre projetos diferentes.

---

> Para dúvidas ou sugestões, consulte a documentação oficial do Puro ou abra uma issue neste repositório.
