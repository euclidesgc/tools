#!/bin/bash

# Script para executar a documentação em localhost
# Ativa o ambiente virtual e executa o servidor MkDocs

LOG_FILE="serve.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Definir cores
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Prevenir execução com -e
if [[ "$-" == *e* ]]; then
    echo -e "${RED}Erro: Não execute este script com o parâmetro -e habilitado.${RESET}" >&2
    exit 1
fi

function criar_ambiente_virtual {
    echo -e "${BLUE}📦 Criando ambiente virtual...${RESET}"
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erro ao criar ambiente virtual${RESET}" >&2
        exit 1
    fi

    echo -e "${YELLOW}⬇️  Instalando dependências...${RESET}"
    source venv/bin/activate
    pip install mkdocs mkdocs-techdocs-core mkdocs-kroki-plugin
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erro ao instalar dependências${RESET}" >&2
        exit 1
    fi
}

function diagnostico {
    echo -e "${BLUE}🔍 Diagnóstico do ambiente...${RESET}"
    echo -e "${GREEN}Python versão:${RESET} $(python3 --version)"
    echo -e "${GREEN}Pip versão:${RESET} $(source venv/bin/activate && pip --version 2>/dev/null || echo 'Pip não instalado')"
    echo -e "${GREEN}MkDocs versão:${RESET} $(mkdocs --version 2>/dev/null || echo 'MkDocs não instalado')"
}

function iniciar_servidor {
    echo -e "${BLUE}🌐 Iniciando servidor em http://127.0.0.1:8000${RESET}"
    source venv/bin/activate && mkdocs serve &
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erro ao iniciar o servidor MkDocs${RESET}" >&2
        exit 1
    fi

    # Abrir navegador padrão na URL do servidor
    sleep 2  # Aguarda o servidor iniciar
    echo -e "${GREEN}Abrindo navegador padrão...${RESET}"
    open http://127.0.0.1:8000
}

function menu {
    echo -e "${YELLOW}====================================================${RESET}"
    echo -e "${BLUE} Menu de Opções ${RESET}"
    echo -e "${YELLOW}====================================================${RESET}"
    echo -e "${GREEN}1.${RESET} Criar ambiente virtual e instalar dependências"
    echo -e "${GREEN}2.${RESET} Diagnóstico do ambiente"
    echo -e "${GREEN}3.${RESET} Iniciar servidor MkDocs"
    echo -e "${GREEN}4.${RESET} Sair"
    echo -e "${YELLOW}====================================================${RESET}"
    read -p "Escolha uma opção: " opcao

    case $opcao in
        1)
            criar_ambiente_virtual
            ;;
        2)
            diagnostico
            ;;
        3)
            iniciar_servidor
            ;;
        4)
            echo -e "${BLUE}Saindo...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${RESET}"
            ;;
    esac
}

while true; do
    menu
done
