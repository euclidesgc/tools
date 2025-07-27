#!/usr/bin/env bash

# Cores para a interface
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m' # Sem Cor

# Emojis
EMOJI_FLUTTER="🎯"
EMOJI_OK="✅"
EMOJI_WARN="⚠️"
EMOJI_ERROR="❌"
EMOJI_INSTALL="⬇️"
EMOJI_REMOVE="🗑️"
EMOJI_UPDATE="🔄"
EMOJI_CLEAN="🧹"
EMOJI_GEAR="⚙️"
EMOJI_EXIT="🚪"

# Variável global para rastrear o status do FVM
FVM_IS_INSTALLED=false

# Função para sair do script
exit_script() {
    printf "\n%b\n" "${GREEN}${EMOJI_OK} Até logo! 👋${NC}"
    exit 0
}

# Função para verificar se o 'fvm' está instalado
check_fvm_installed() {
    if command -v fvm &> /dev/null; then
        FVM_IS_INSTALLED=true
    else
        FVM_IS_INSTALLED=false
    fi
}

# Função para exibir o cabeçalho
show_header() {
    clear
    printf "%b\n" "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    printf "%b\n" "${CYAN}║         ${EMOJI_FLUTTER}  ${YELLOW}FVM Manager - Flutter Env${CYAN}   ${EMOJI_FLUTTER}               ║${NC}"
    printf "%b\n" "${CYAN}║   ${GREEN}Gerencie seus ambientes Flutter com mais facilidade${CYAN}    ║${NC}"
    printf "%b\n" "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Função para aguardar o usuário pressionar Enter
wait_for_enter() {
    echo
    read -p "$(printf "%b" "${YELLOW}Pressione Enter para voltar ao menu... ${EMOJI_GEAR}${NC}")"
}

# Função de aviso genérica para quando o FVM não está instalado
fvm_not_installed_warning() {
    show_header
    printf "%b\n" "${RED}${EMOJI_ERROR} FVM não está instalado.${NC}"
    printf "%b\n" "${YELLOW}Por favor, instale o FVM primeiro usando o menu 'Gerenciar FVM & Projeto'.${NC}"
    wait_for_enter
}

#-------------------------------------------------------------------------------
# MENU 1: INSTALAR VERSÕES DO FLUTTER
#-------------------------------------------------------------------------------
menu_instalar_versoes() {
    if [ "$FVM_IS_INSTALLED" = false ]; then
        fvm_not_installed_warning
        return
    fi

    while true; do
        show_header
        printf "%b\n" "${BLUE}${EMOJI_FLUTTER} Qual canal você deseja instalar?${NC}"
        echo
        printf "  ${GREEN}1)${NC} ${EMOJI_OK}  Listar versões do canal ${GREEN}STABLE${NC}\n"
        printf "  ${CYAN}2)${NC} ${EMOJI_WARN}   Instalar uma versão do canal ${CYAN}BETA${NC} por nome\n"
        printf "  ${RED}0)${NC} ${EMOJI_EXIT}  Voltar ao menu principal\n"
        printf "  ${RED}q)${NC} ${EMOJI_EXIT}  Terminar Script\n"
        echo
        read -p "Digite a opção desejada: " escolha

        case $escolha in
            1) menu_list_stable_releases ;;
            2) menu_install_beta ;;
            0) return ;;
            [qQ]) exit_script ;;
            *)
                printf "\n%b\n" "${RED}${EMOJI_ERROR} Opção inválida. Tente novamente.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Submenu para instalar versões BETA por nome
menu_install_beta() {
    while true; do
        show_header
        printf "%b\n" "${MAGENTA}${EMOJI_INSTALL} Instalar uma versão do canal BETA${NC}"
        printf "%b\n" "   - Digite ${CYAN}beta${NC} para instalar a versão beta mais recente."
        printf "%b\n" "   - Digite um número de versão específico (ex: ${CYAN}3.35.0-0.1.pre${NC})."
        echo
        read -p "$(printf "%b" "Digite a versão beta [${RED}0 para Voltar, q para Terminar${NC}]: ")" versao_beta

        case "$versao_beta" in
            0) return ;;
            [qQ]) exit_script ;;
            "") continue ;;
            *)
                printf "\n%b\n" "${CYAN}${EMOJI_INSTALL} Instalando Flutter ${versao_beta}...${NC}"
                fvm install "$versao_beta"
                printf "\n%b\n" "${GREEN}${EMOJI_OK} Versão '${versao_beta}' instalada com sucesso!${NC}"
                wait_for_enter
                return
                ;;
        esac
    done
}

# Submenu para listar e instalar versões STABLE
menu_list_stable_releases() {
    while true; do
        show_header
        printf "%b\n" "${MAGENTA}${EMOJI_INSTALL} Selecione uma versão STABLE para instalar:${NC}"

        local releases=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && releases+=("$line")
        done < <(fvm releases | sed 's/\x1b\[[0-9;]*m//g' | grep '│' | grep -v 'Version' | awk -F '│' '{print $2}' | sed 's/v//' | awk '{$1=$1;print}' | sort -Vru | grep .)

        local installed=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && installed+=("$line")
        done < <(fvm list | sed 's/\x1b\[[0-9;]*m//g' | grep '│' | grep -v 'Version' | awk -F '│' '{print $2}' | awk '{$1=$1;print}')

        local opcoes=()
        for i in "${!releases[@]}"; do
            local versao="${releases[$i]}"
            local status=""
            for inst in "${installed[@]}"; do
                if [[ "$inst" == "$versao" ]]; then
                    status="${GREEN} [Instalada]${NC}"
                    break
                fi
            done
            printf "  ${YELLOW}%2d)${NC} ${EMOJI_FLUTTER} %s%b\n" "$((i+1))" "$versao" "$status"
            opcoes+=("$versao")
        done
        printf "   ${RED}0)${NC} ${EMOJI_EXIT} Voltar\n"
        printf "   ${RED}q)${NC} ${EMOJI_EXIT} Terminar Script\n"

        echo
        read -p "Digite sua escolha: " escolha

        case "$escolha" in
            [qQ]) exit_script ;;
            0) return ;;
        esac

        if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 1 ] && [ "$escolha" -le ${#opcoes[@]} ]; then
            local versao_selecionada="${opcoes[$((escolha-1))]}"
            printf "\n%b\n" "${CYAN}${EMOJI_INSTALL} Instalando Flutter ${versao_selecionada}...${NC}"
            fvm install "$versao_selecionada"
            printf "\n%b\n" "${GREEN}${EMOJI_OK} Versão '${versao_selecionada}' instalada com sucesso!${NC}"
            wait_for_enter
            break
        else
            printf "\n%b\n" "${RED}${EMOJI_ERROR} Opção inválida. Tente novamente.${NC}"
            sleep 2
        fi
    done
}


#-------------------------------------------------------------------------------
# MENU 2: GERENCIAR VERSÕES INSTALADAS
#-------------------------------------------------------------------------------
menu_gerenciar_instaladas() {
    if [ "$FVM_IS_INSTALLED" = false ]; then
        fvm_not_installed_warning
        return
    fi

    while true; do
        show_header
        printf "%b\n" "${BLUE}${EMOJI_GEAR}  Selecione uma versão instalada para gerenciar:${NC}"
        echo

        # Extrai as linhas da tabela, já sem cores
        local lines=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && lines+=("$line")
        done < <(fvm list | sed 's/\x1b\[[0-9;]*m//g' | grep '│' | grep -v 'Version')

        if [ ${#lines[@]} -eq 0 ]; then
            printf "\n%b\n" "${YELLOW}${EMOJI_WARN} Nenhuma versão do Flutter instalada via FVM.${NC}"
            wait_for_enter
            return
        fi

        local opcoes=()
        for i in "${!lines[@]}"; do
            local linha="${lines[$i]}"

            # Extrai os dados de cada coluna pelo delimitador │
            local nome_versao=$(echo "$linha" | awk -F '│' '{print $2}' | awk '{$1=$1;print}')
            local global_col=$(echo "$linha" | awk -F '│' '{print $7}')
            local local_col=$(echo "$linha" | awk -F '│' '{print $8}')

            local status=""
            local cor=$NC

            # Verifica a coluna "Global"
            if [[ "$global_col" == *"●"* ]]; then
                status=" [Global]"
                cor=$GREEN
            fi

            # Verifica a coluna "Local"
            if [[ "$local_col" == *"●"* ]]; then
                status=" [Local]"
                cor=$CYAN
            fi

            printf "  ${YELLOW}%2d)${NC} ${EMOJI_FLUTTER} %b%s%b\n" "$((i+1))" "$cor" "$nome_versao" "$status"
            opcoes+=("$nome_versao")
        done
        printf "   ${RED}0)${NC} ${EMOJI_EXIT} Voltar ao menu principal\n"
        printf "   ${RED}q)${NC} ${EMOJI_EXIT} Terminar Script\n"

        echo
        read -p "Digite a sua escolha: " escolha

        case "$escolha" in
            [qQ]) exit_script ;;
            0) return ;;
        esac

        if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 1 ] && [ "$escolha" -le ${#opcoes[@]} ]; then
            local versao_selecionada="${opcoes[$((escolha-1))]}"

            while true; do
                show_header
                printf "%b\n" "${BLUE}${EMOJI_GEAR}  O que você deseja fazer com a versão '${YELLOW}${versao_selecionada}${BLUE}'?${NC}"
                echo
                printf "  ${YELLOW}1)${NC} ${EMOJI_OK}  Definir como ${GREEN}Global${NC}\n"
                printf "  ${YELLOW}2)${NC} ${EMOJI_FLUTTER}  Usar neste ${CYAN}Projeto${NC}\n"
                printf "  ${RED}3)${NC} ${EMOJI_REMOVE}   Remover esta versão\n"
                printf "  ${RED}0)${NC} ${EMOJI_EXIT}  Voltar\n"
                printf "  ${RED}q)${NC} ${EMOJI_EXIT}  Terminar Script\n"

                read -p "Escolha uma ação: " acao
                case $acao in
                    1)
                        printf "\n%b\n" "${CYAN}${EMOJI_OK} Definindo '${versao_selecionada}' como global...${NC}"
                        fvm global "$versao_selecionada"
                        printf "\n%b\n" "${GREEN}${EMOJI_OK} Feito!${NC}"
                        wait_for_enter; break ;;
                    2)
                        printf "\n%b\n" "${CYAN}${EMOJI_FLUTTER} Usando '${versao_selecionada}' neste projeto...${NC}"
                        fvm use "$versao_selecionada"
                        printf "\n%b\n" "${GREEN}${EMOJI_OK} Versão definida! Rode 'fvm flutter --version' para confirmar.${NC}"
                        wait_for_enter; break ;;
                    3)
                        read -p "$(printf "%b" "${RED}${EMOJI_REMOVE} Tem certeza que deseja remover a versão '${versao_selecionada}'? (s/N): ${NC}")" confirm
                        if [[ "$confirm" =~ ^[sS]$ ]]; then
                            printf "\n%b\n" "${CYAN}${EMOJI_REMOVE} Removendo versão...${NC}"
                            fvm remove "$versao_selecionada"
                            printf "\n%b\n" "${GREEN}${EMOJI_OK} Versão removida!${NC}"
                        else
                            printf "\n%b\n" "${YELLOW}${EMOJI_WARN} Remoção cancelada.${NC}"
                        fi
                        wait_for_enter; break ;;
                    0) break ;;
                    [qQ]) exit_script ;;
                    *) printf "\n%b\n" "${RED}${EMOJI_ERROR} Ação inválida.${NC}" ; sleep 2 ;;
                esac
            done
        else
            printf "\n%b\n" "${RED}${EMOJI_ERROR} Opção inválida. Tente novamente.${NC}"
            sleep 2
        fi
    done
}


#-------------------------------------------------------------------------------
# MENU 3: GERENCIAR FVM E PROJETO
#-------------------------------------------------------------------------------
menu_gerenciar_fvm() {
    while true; do
        show_header
        printf "%b\n" "${BLUE}${EMOJI_GEAR}  Gerenciar FVM & Projeto:${NC}"
        echo
        printf "  ${GREEN}1)${NC} ${EMOJI_INSTALL}   Instalar FVM\n"
        printf "  ${YELLOW}2)${NC} ${EMOJI_UPDATE} Configurar o PATH do FVM no shell (zshrc)\n"
        printf "  ${CYAN}3)${NC} ${EMOJI_GEAR}  Ver qual versão está em uso\n"
        printf "  ${YELLOW}4)${NC} ${EMOJI_CLEAN} Limpar configuração FVM do projeto\n"
        printf "  ${RED}5)${NC} ${EMOJI_REMOVE}   Desinstalar FVM\n"
        printf "  ${RED}0)${NC} ${EMOJI_EXIT}  Voltar ao menu principal\n"
        printf "  ${RED}q)${NC} ${EMOJI_EXIT}  Terminar Script\n"

        echo
        read -p "Digite o número da opção desejada: " escolha

        case $escolha in
            1) # INSTALAR FVM
                show_header
                if [ "$FVM_IS_INSTALLED" = true ]; then
                    printf "%b\n" "${YELLOW}${EMOJI_WARN} FVM já está instalado.${NC}"
                else
                    if ! command -v dart &> /dev/null; then
                        printf "\n%b\n" "${RED}${EMOJI_ERROR} ERRO: O comando 'dart' não foi encontrado.${NC}"
                        printf "%b\n" "${YELLOW}Não é possível instalar o FVM. Por favor, instale o SDK do Flutter primeiro.${NC}"
                    else
                        printf "\n%b\n" "${CYAN}${EMOJI_INSTALL} Instalando FVM via 'dart pub global activate fvm'...${NC}"
                        if dart pub global activate fvm; then
                            printf "\n%b\n" "${GREEN}${EMOJI_OK} FVM instalado com sucesso!${NC}"
                            FVM_IS_INSTALLED=true
                        else
                            printf "\n%b\n" "${RED}${EMOJI_ERROR} A instalação do FVM falhou.${NC}"
                        fi
                    fi
                fi
                wait_for_enter
                ;;
            2) # CONFIGURAR PATH
                show_header
                printf "%b\n" "${CYAN}${EMOJI_GEAR} Adicionando o PATH do FVM ao seu ~/.zshrc...${NC}"
                local ZSHRC="$HOME/.zshrc"
                local FVM_PATH_LINE='export PATH="$PATH":"$HOME/fvm/default/bin"'
                if grep -q "$FVM_PATH_LINE" "$ZSHRC"; then
                    printf "\n%b\n" "${YELLOW}${EMOJI_WARN} O PATH do FVM já está configurado no ~/.zshrc.${NC}"
                else
                    echo -e "\n# FVM PATH\n$FVM_PATH_LINE" >> "$ZSHRC"
                    printf "\n%b\n" "${GREEN}${EMOJI_OK} Configuração do PATH adicionada com sucesso!${NC}"
                    printf "%b\n" "${YELLOW}Por favor, feche e reabra seu terminal para a mudança ter efeito.${NC}"
                fi
                wait_for_enter
                ;;
            3) # VERIFICAR VERSÃO
                if [ "$FVM_IS_INSTALLED" = false ]; then fvm_not_installed_warning; continue; fi
                show_header
                printf "%b\n" "${CYAN}${EMOJI_GEAR} Verificando a versão do Flutter em uso...${NC}"
                fvm flutter --version
                wait_for_enter
                ;;
            4) # LIMPAR PROJETO
                if [ "$FVM_IS_INSTALLED" = false ]; then fvm_not_installed_warning; continue; fi
                show_header
                printf "%b\n" "${CYAN}${EMOJI_CLEAN} Limpando configuração FVM do projeto atual...${NC}"
                rm -rf .fvm
                printf "\n%b\n" "${GREEN}${EMOJI_OK} Configuração FVM do projeto removida!${NC}"
                wait_for_enter
                ;;
            5) # DESINSTALAR FVM
                if [ "$FVM_IS_INSTALLED" = false ]; then fvm_not_installed_warning; continue; fi
                show_header
                read -p "$(printf "%b" "${RED}${EMOJI_REMOVE} Tem certeza que deseja desinstalar o FVM? (s/N): ${NC}")" confirm
                if [[ "$confirm" =~ ^[sS]$ ]]; then
                    printf "\n%b\n" "${CYAN}${EMOJI_REMOVE} Desinstalando FVM...${NC}"
                    if dart pub global deactivate fvm; then
                         printf "\n%b\n" "${GREEN}${EMOJI_OK} FVM desinstalado com sucesso!${NC}"
                         FVM_IS_INSTALLED=false
                    else
                         printf "\n%b\n" "${RED}${EMOJI_ERROR} Falha ao desinstalar o FVM.${NC}"
                    fi
                else
                    printf "\n%b\n" "${YELLOW}${EMOJI_WARN} Operação cancelada.${NC}"
                fi
                wait_for_enter
                ;;
            0) return ;;
            [qQ]) exit_script ;;
            *)
                printf "\n%b\n" "${RED}${EMOJI_ERROR} Opção inválida. Tente novamente.${NC}"
                sleep 2
                ;;
        esac
    done
}


#-------------------------------------------------------------------------------
# MENU PRINCIPAL
#-------------------------------------------------------------------------------
main_menu() {
    while true; do
        check_fvm_installed
        show_header

        if [ "$FVM_IS_INSTALLED" = false ]; then
            printf "%b\n" " ${YELLOW}${EMOJI_WARN} AVISO: FVM não está instalado.${NC}"
            printf "%b\n" "   Algumas opções não funcionarão. Use o menu ${CYAN}3${NC} para instalar."
            echo
        fi

        printf "%b\n" "${BLUE}${EMOJI_GEAR}  O que você gostaria de fazer?${NC}"
        echo
        printf "  ${YELLOW}1)${NC} ${EMOJI_INSTALL}   Listar e instalar versões do Flutter\n"
        printf "  ${GREEN}2)${NC} ${EMOJI_FLUTTER}  Gerenciar versões instaladas\n"
        printf "  ${CYAN}3)${NC} ${EMOJI_GEAR}   Gerenciar FVM & Projeto\n"
        printf "  ${RED}q)${NC} ${EMOJI_EXIT}  Terminar Script\n"

        echo
        read -p "Digite o número da opção desejada: " escolha

        case $escolha in
            1) menu_instalar_versoes ;;
            2) menu_gerenciar_instaladas ;;
            3) menu_gerenciar_fvm ;;
            [qQ]) exit_script ;;
            *)
                printf "\n%b\n" "${RED}${EMOJI_ERROR} Opção inválida. Por favor, escolha uma das opções acima.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Inicia o script
main_menu