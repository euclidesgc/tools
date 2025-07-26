#!/usr/bin/env bash

# Cores para a interface
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem Cor

# Função para verificar se o 'puro' está instalado
check_puro_installed() {
    if ! command -v puro &> /dev/null; then
        printf "%b\n" "${RED}ERRO: O comando 'puro' não foi encontrado.${NC}"
        printf "%b\n" "${YELLOW}Por favor, instale o Puro para usar este script.${NC}"
        printf "%b\n" "Visite: https://puro.dev/"
        exit 1
    fi
}

# Função para exibir o cabeçalho
show_header() {
    clear
    printf "%b\n" "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    printf "%b\n" "${CYAN}║                   ${YELLOW}PURO Manager - Flutter Env${CYAN}                  ║${NC}"
    printf "%b\n" "${CYAN}║      ${GREEN}Gerencie seus ambientes Flutter com mais facilidade${CYAN}      ║${NC}"
    printf "%b\n" "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Função para aguardar o usuário pressionar Enter
wait_for_enter() {
    echo
    read -p "$(printf "%b" "${YELLOW}Pressione Enter para voltar ao menu...${NC}")"
}

#-------------------------------------------------------------------------------
# FUNÇÕES DE INSTALAÇÃO (MENU 1)
#-------------------------------------------------------------------------------
create_installation_menu() {
    local title="$1"
    local filter_pattern="$2"

    while true; do
        show_header
        printf "%b\n" "${BLUE}${title}${NC}"

        local instalados=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && instalados+=("$(echo "$line" | awk '{print $1}')")
        done < <(puro ls | sed 's/\x1b\[[0-9;]*m//g' | grep -v 'not installed' | grep -E "^\s*(~|\*)?\s*[a-zA-Z0-9].*\s+\(")

        local disponiveis=()
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                if echo "$line" | grep -qE "$filter_pattern"; then
                    disponiveis+=("$line")
                fi
            fi
        done < <(puro ls-versions | sed 's/\x1b\[[0-9;]*m//g' | grep -oE 'Flutter [0-9]+\.[0-9]+\.[^ |]+' | awk '{print $2}' | sort -Vru)

        local opcoes=()
        for i in "${!disponiveis[@]}"; do
            local versao="${disponiveis[$i]}"
            local status=""
            for instalado in "${instalados[@]}"; do
                if [[ "$instalado" == "$versao" ]]; then
                    status="${GREEN} [Instalada]${NC}"
                    break
                fi
            done
            printf "  ${YELLOW}%2d)${NC} Flutter %s%b\n" "$((i+1))" "$versao" "$status"
            opcoes+=("$versao")
        done
        printf "   ${RED}0)${NC} Voltar\n"

        echo
        read -p "Digite o número da versão para instalar: " escolha

        if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 0 ] && [ "$escolha" -le ${#opcoes[@]} ]; then
            if [ "$escolha" -eq 0 ]; then
                return
            fi

            local idx=$((escolha - 1))
            local versao_selecionada="${opcoes[$idx]}"
            local nome_env=${versao_selecionada}

            printf "\n%b\n" "${CYAN}Instalando Flutter ${versao_selecionada} no ambiente '${nome_env}'...${NC}"
            puro create "$nome_env" "$versao_selecionada"
            printf "\n%b\n" "${GREEN}Ambiente '${nome_env}' criado com sucesso!${NC}"
            wait_for_enter
        else
            printf "\n%b\n" "${RED}Opção inválida. Tente novamente.${NC}"
            sleep 2
        fi
    done
}


menu_instalar_versoes() {
    while true; do
        show_header
        printf "%b\n" "${BLUE}Qual canal você deseja listar?${NC}"
        printf "  ${YELLOW}1)${NC} Versões do canal ${GREEN}STABLE${NC}\n"
        printf "  ${YELLOW}2)${NC} Versões do canal ${CYAN}BETA${NC}\n"
        printf "  ${RED}0)${NC} Voltar ao menu principal\n"
        echo
        read -p "Digite a opção desejada: " escolha_canal

        case $escolha_canal in
            1)
                create_installation_menu "Selecione uma versão STABLE para instalar:" '^[0-9]+\.[0-9]+\.[0-9]+$'
                ;;
            2)
                create_installation_menu "Selecione uma versão BETA para instalar:" '\.pre'
                ;;
            0)
                return
                ;;
            *)
                printf "\n%b\n" "${RED}Opção inválida. Tente novamente.${NC}"
                sleep 2
                ;;
        esac
    done
}


#-------------------------------------------------------------------------------
# OPÇÃO 2: GERENCIAR VERSÕES INSTALADAS (LÓGICA SUPER CORRIGIDA)
#-------------------------------------------------------------------------------
menu_gerenciar_instaladas() {
    while true; do
        show_header
        printf "%b\n" "${BLUE}Selecione um ambiente para gerenciar:${NC}"

        local lines=()
        while IFS= read -r line; do
             [[ -n "$line" ]] && lines+=("$line")
        done < <(puro ls | sed 's/\x1b\[[0-9;]*m//g' | grep -E "^\s*(~|\*)?\s*[a-zA-Z0-9].*\s+\(")

        if [ ${#lines[@]} -eq 0 ]; then
            printf "\n%b\n" "${YELLOW}Nenhum ambiente Flutter encontrado.${NC}"
            wait_for_enter
            return
        fi

        local ambientes_selecionaveis=()

        for i in "${!lines[@]}"; do
            local linha_original="${lines[$i]}"
            local nome_ambiente=""
            local status_texto=""
            local status_cor=$NC

            # Sempre pega o primeiro campo que não seja ~ ou *
            nome_ambiente=$(echo "$linha_original" | awk '{for(i=1;i<=NF;i++) if($i != "~" && $i != "*") {print $i; break}}')

            # Status visual
            if [[ "$linha_original" =~ ^~ ]]; then
                status_cor=$GREEN
                status_texto=" [Ativo Global]"
            fi

            if [[ "$linha_original" =~ 'not installed' ]]; then
                status_cor=$YELLOW
                status_texto=" [Não Instalado]"
            fi

            printf "  ${YELLOW}%2d)${NC} %b%s%b\n" "$((i+1))" "$status_cor" "$linha_original" "$status_texto"
            ambientes_selecionaveis+=("$nome_ambiente")
        done
        printf "   ${RED}0)${NC} Voltar ao menu principal\n"

        echo
        read -p "Digite o número do ambiente: " escolha

        if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 0 ] && [ "$escolha" -le ${#ambientes_selecionaveis[@]} ]; then
            if [ "$escolha" -eq 0 ]; then
                return
            fi

            local idx=$((escolha - 1))
            local env_selecionado="${ambientes_selecionaveis[$idx]}"
            local linha_selecionada="${lines[$idx]}"

            if [[ "$linha_selecionada" =~ 'not installed' ]]; then
                 read -p "$(printf "%b" "${YELLOW}O ambiente '${env_selecionado}' não está instalado. Deseja instalar agora? (s/N): ${NC}")" confirm
                 if [[ "$confirm" =~ ^[sS]$ ]]; then
                     printf "\n%b\n" "${CYAN}Instalando Flutter ${env_selecionado}...${NC}"
                     puro create "$env_selecionado"
                     printf "\n%b\n" "${GREEN}Ambiente '${env_selecionado}' instalado com sucesso!${NC}"
                     wait_for_enter
                 fi
                 continue
            fi

            show_header
            printf "%b\n" "${BLUE}O que você deseja fazer com o ambiente '${YELLOW}${env_selecionado}${BLUE}'?${NC}"
            printf "  ${YELLOW}1)${NC} Definir como global\n"
            printf "  ${YELLOW}2)${NC} Usar no projeto atual\n"
            printf "  ${RED}3)${NC} Remover este ambiente\n"
            printf "  ${RED}0)${NC} Voltar\n"

            read -p "Escolha uma ação: " acao
            case $acao in
                1)
                    printf "\n%b\n" "${CYAN}Definindo '${env_selecionado}' como global...${NC}"
                    puro use "$env_selecionado" --global
                    printf "\n%b\n" "${GREEN}Feito!${NC}"
                    ;;
                2)
                    printf "\n%b\n" "${CYAN}Usando '${env_selecionado}' no projeto atual...${NC}"
                    puro use "$env_selecionado"
                    printf "\n%b\n" "${GREEN}Feito!${NC}"
                    ;;
                3)
                    read -p "$(printf "%b" "${RED}Tem certeza que deseja remover o ambiente '${env_selecionado}'? (s/N): ${NC}")" confirm
                    if [[ "$confirm" =~ ^[sS]$ ]]; then
                        printf "\n%b\n" "${CYAN}Removendo ambiente...${NC}"
                        puro rm "$env_selecionado" -f
                        printf "\n%b\n" "${GREEN}Ambiente removido!${NC}"
                    else
                        printf "\n%b\n" "${YELLOW}Remoção cancelada.${NC}"
                    fi
                    ;;
                0)
                    continue ;;
                *)
                    printf "\n%b\n" "${RED}Ação inválida.${NC}" ;;
            esac
            wait_for_enter
        else
            printf "\n%b\n" "${RED}Opção inválida. Tente novamente.${NC}"
            sleep 2
        fi
    done
}


#-------------------------------------------------------------------------------
# OPÇÃO 3: GERENCIAR PURO
#-------------------------------------------------------------------------------
menu_gerenciar_puro() {
    while true; do
        show_header
        printf "%b\n" "${BLUE}Gerenciar Puro:${NC}"
        printf "  ${YELLOW}1)${NC} Atualizar o Puro\n"
        printf "  ${RED}2)${NC} Desinstalar o Puro\n"
        printf "  ${CYAN}3)${NC} Checar versão do Puro\n"
        printf "  ${YELLOW}4)${NC} Limpar caches não usados (gc)\n"
        printf "  ${YELLOW}5)${NC} Limpar configuração do projeto atual (clean)\n"
        printf "  ${RED}0)${NC} Voltar ao menu principal\n"

        echo
        read -p "Digite o número da opção desejada: " escolha

        case $escolha in
            1)
                show_header
                printf "%b\n" "${CYAN}Atualizando Puro...${NC}"
                puro upgrade-puro
                printf "\n%b\n" "${GREEN}Puro atualizado!${NC}"
                wait_for_enter
                ;;
            2)
                show_header
                read -p "$(printf "%b" "${RED}TEM CERTEZA que deseja desinstalar o Puro do seu sistema? (s/N): ${NC}")" confirm
                if [[ "$confirm" =~ ^[sS]$ ]]; then
                    printf "\n%b\n" "${CYAN}Desinstalando Puro...${NC}"
                    puro uninstall-puro
                    printf "\n%b\n" "${GREEN}Puro desinstalado. Este script não funcionará mais.${NC}"
                    exit 0
                else
                    printf "\n%b\n" "${YELLOW}Operação cancelada.${NC}"
                    sleep 2
                fi
                ;;
            3)
                show_header
                printf "%b\n" "${CYAN}Verificando versão...${NC}"
                puro --version
                wait_for_enter
                ;;
            4)
                show_header
                printf "%b\n" "${CYAN}Limpando caches não utilizados...${NC}"
                puro gc
                printf "\n%b\n" "${GREEN}Limpeza concluída!${NC}"
                wait_for_enter
                ;;
            5)
                show_header
                printf "%b\n" "${CYAN}Limpando arquivos de configuração do Puro do projeto atual...${NC}"
                puro clean
                printf "\n%b\n" "${GREEN}Limpeza concluída!${NC}"
                wait_for_enter
                ;;
            0)
                return ;;
            *)
                printf "\n%b\n" "${RED}Opção inválida. Tente novamente.${NC}"
                sleep 2
                ;;
        esac
    done
}


#-------------------------------------------------------------------------------
# MENU PRINCIPAL
#-------------------------------------------------------------------------------
main_menu() {
    check_puro_installed
    while true; do
        show_header
        printf "%b\n" "${BLUE}O que você gostaria de fazer?${NC}"
        printf "  ${YELLOW}1)${NC} Listar e instalar versões do Flutter\n"
        printf "  ${YELLOW}2)${NC} Gerenciar ambientes Flutter\n"
        printf "  ${CYAN}3)${NC} Gerenciar a ferramenta Puro\n"
        printf "  ${RED}0)${NC} Sair\n"

        echo
        read -p "Digite o número da opção desejada: " escolha

        case $escolha in
            1) menu_instalar_versoes ;;
            2) menu_gerenciar_instaladas ;;
            3) menu_gerenciar_puro ;;
            0)
                printf "\n%b\n" "${GREEN}Até logo! 👋${NC}"
                exit 0
                ;;
            *)
                printf "\n%b\n" "${RED}Opção inválida. Por favor, escolha uma das opções acima.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Inicia o script
main_menu