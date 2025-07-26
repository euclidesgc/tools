# MkDocs Serve (`serve.sh`)

Este script automatiza a criação de ambiente virtual, instalação de dependências e execução do servidor [MkDocs](https://www.mkdocs.org/) para documentação local.

## Funcionalidades
- **Criar ambiente virtual Python**: Isola dependências para evitar conflitos com outros projetos.
- **Instalar dependências**: Instala MkDocs, mkdocs-techdocs-core e mkdocs-kroki-plugin.
- **Diagnóstico do ambiente**: Mostra versões do Python, pip e MkDocs.
- **Iniciar servidor MkDocs**: Sobe a documentação localmente e abre o navegador automaticamente.
- **Menu interativo**: Interface simples para executar cada etapa separadamente.
- **Log automático**: Todas as ações são registradas em `serve.log`.

## Como usar
1. Dê permissão de execução ao script:
   ```bash
   chmod +x serve.sh
   ```
2. Execute o script:
   ```bash
   ./serve.sh
   ```

## Requisitos
- Python 3
- Bash 4+
- macOS ou Linux

## Recomendações
- Execute o script fora de ambientes virtuais já ativados.
- Consulte o arquivo `serve.log` para detalhes de execução e diagnóstico.

---

> Para dúvidas ou sugestões, consulte a documentação oficial do MkDocs ou abra uma issue neste repositório.
