# 🦋 Puro Manager - Flutter Env

> Gerencie múltiplos ambientes Flutter de forma simples, visual e segura!

## ✨ O que é?

O **Puro Manager** (`puro-manager.sh`) é um script interativo para facilitar a instalação, gerenciamento e remoção de ambientes Flutter usando o [Puro](https://puro.dev/). Ele oferece uma interface intuitiva para tornar a experiência mais agradável.

## 🚀 Funcionalidades

- Listar e instalar versões do Flutter (Stable e Beta)
- Gerenciar ambientes Flutter instalados (definir global, usar no projeto, remover)
- Gerenciar a ferramenta Puro (atualizar, desinstalar, limpar caches e configs)


## 🛠️ Pré-requisitos

- [Puro](https://puro.dev/) instalado no sistema
- Bash 4+ (macOS ou Linux)

## ⚡ Instalação do Puro

```sh
curl -fsSL https://puro.dev/install.sh | bash
```

## 📦 Como usar o script

1. Dê permissão de execução ao script:
   ```sh
   chmod +x puromng.sh
   ```
2. Execute:
   ```sh
   ./puromng.sh
   ```

## 🖥️ Menu principal

- `1️⃣ Listar e instalar versões do Flutter`
  Veja todas as versões disponíveis e instale com um clique.
- `2️⃣ Gerenciar ambientes Flutter`
  Defina global, use no projeto ou remova ambientes facilmente.
- `3️⃣ Gerenciar a ferramenta Puro`
  Atualize, desinstale ou limpe caches/configurações do Puro.
- `0️⃣ Sair`
  Encerre o gerenciador.

## 📋 Exemplo de uso

![Exemplo de uso do menu](../assets/puro-manager-demo.png)

## 📝 Observações

- O script verifica se o `puro` está instalado antes de iniciar.
- Todas as ações são feitas via comandos do próprio Puro.
- Mensagens de erro e sucesso são exibidas com cores e emojis para melhor experiência.

---

> Sinta-se livre para contribuir ou sugerir melhorias!
