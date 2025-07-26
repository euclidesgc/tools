# Função para desinstalar o Puro
uninstall_puro() {
    show_header
    printf "%b\n" "${RED}Desinstalar Puro:${NC}"
    printf "%b\n" "Isso irá remover o binário do Puro e a linha do PATH do ~/.zshrc."
    read -p "Tem certeza que deseja desinstalar o Puro? (s/N): " confirm
    if [[ "$confirm" =~ ^[sS]$ ]]; then
        rm -rf "$HOME/.puro"
        sed -i '' '/export PATH=\"\$HOME\/\.puro\/bin:\$PATH\"/d' ~/.zshrc
        printf "%b\n" "${GREEN}Puro desinstalado com sucesso!${NC}"
    else
        printf "%b\n" "${YELLOW}Desinstalação cancelada.${NC}"
    fi
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}
#!/bin/bash

# Cores para menus
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para exibir cabeçalho
show_header() {
    clear
    printf "%b\n" "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    printf "%b\n" "${CYAN}║            ${YELLOW}PURO Manager - Flutter Env${CYAN}            ║${NC}"
    printf "%b\n" "${CYAN}║      ${GREEN}Gerencie ambientes Flutter facilmente${CYAN}       ║${NC}"
    printf "%b\n" "${CYAN}║    ${RED}Para sair, pressione Ctrl + C no terminal.${CYAN}    ║${NC}"
    printf "%b\n" "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo
}

# Função para instalar o Puro
install_puro() {
    show_header
    printf "%b\n" "${YELLOW}Instalando ou atualizando Puro...${NC}"
    curl -fsSL https://puro.dev/install.sh | bash
    export PATH="$HOME/.puro/bin:$PATH"
    if ! grep -q 'export PATH="$HOME/.puro/bin:$PATH"' ~/.zshrc; then
        echo 'export PATH="$HOME/.puro/bin:$PATH"' >> ~/.zshrc
    fi
    printf "%b\n" "${GREEN}Puro instalado ou atualizado com sucesso!${NC}"
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para listar ambientes
list_ambientes() {
    show_header
    printf "%b\n" "${BLUE}Ambientes disponíveis:${NC}"
    ambientes=()
    ambientes_usados=()
    # Filtra nomes de ambientes: remove ANSI, pega só linhas que começam com espaços, pega só o primeiro campo
    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        if echo "$clean" | grep -qE '^  '; then
            nome=$(echo "$clean" | awk '{print $1}')
            if [ -n "$nome" ] && [[ ! "$nome" =~ ^\(|\)$ ]]; then
                # Verifica se está em uso
                usado=""
                if [ -n "$(puro where "$nome" 2>/dev/null | grep -v '^$')" ]; then
                    usado=" [usado]"
                fi
                ambientes+=("$nome$usado")
            fi
        fi
    done <<< "$(puro ls)"
    if [ ${#ambientes[@]} -eq 0 ]; then
        printf "%b\n" "${RED}Nenhum ambiente encontrado.${NC}"
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi
    printf "%b\n" "${BLUE}Selecione um ambiente:${NC}"
    for i in "${!ambientes[@]}"; do
        idx=$((i+1))
        printf "%b\n" "  $idx) ${GREEN}${ambientes[$i]}${NC}"
    done
    printf "%b\n" "  0) Voltar"
    while true; do
        read -p "Digite o número do ambiente desejado: " escolha
        if [[ "$escolha" =~ ^[0-9]+$ ]]; then
            if [ "$escolha" -eq 0 ]; then
                break
            elif [ "$escolha" -ge 1 ] && [ "$escolha" -le ${#ambientes[@]} ]; then
                env="${ambientes[$((escolha-1))]}"
                printf "%b\n" "${GREEN}Você selecionou o ambiente: '$env'${NC}"
                # Aqui você pode adicionar ações, como mostrar detalhes, ativar, remover, etc.
                break
            else
                printf "%b\n" "${RED}Opção inválida.${NC}"
            fi
        else
            printf "%b\n" "${RED}Digite apenas números.${NC}"
        fi
    done
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para listar versões do Flutter
list_versions() {
    show_header
    printf "%b\n" "${BLUE}Versões do Flutter disponíveis:${NC}"
    puro ls-versions
    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para criar novo ambiente
create_ambiente() {
    show_header
    printf "%b\n" "${BLUE}Criar novo ambiente Flutter:${NC}"
    read -p "Nome do novo ambiente: " env
    puro create "$env"
    echo
    printf "%b\n" "${GREEN}Ambiente '$env' criado!${NC}"
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para usar ambiente
use_ambiente() {
    show_header
    printf "%b\n" "${BLUE}Selecione um ambiente para usar:${NC}"
    ambientes=()
    for linha in $(puro ls); do
        [ -n "$linha" ] && ambientes+=("$linha")
    done
    if [ ${#ambientes[@]} -eq 0 ]; then
        printf "%b\n" "${RED}Nenhum ambiente encontrado.${NC}"
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi
    select env in "${ambientes[@]}" "Cancelar"; do
        if [ "$env" = "Cancelar" ]; then
            break
        elif [ -n "$env" ]; then
            puro use "$env"
            echo
            printf "%b\n" "${GREEN}Ambiente '$env' ativado!${NC}"
            break
        else
            printf "%b\n" "${RED}Opção inválida.${NC}"
        fi
    done
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para atualizar o Puro
upgrade_puro() {
    show_header
    printf "%b\n" "${BLUE}Atualizando Puro...${NC}"
    puro upgrade-puro
    echo
    printf "%b\n" "${GREEN}Puro atualizado!${NC}"
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para exibir o menu principal
show_main_menu() {
    printf "%b\n" "${BLUE}Selecione uma opção:${NC}"
    echo
    printf "%b\n" "${GREEN}1.${NC} Listar ambientes"
    printf "%b\n" "${GREEN}2.${NC} Listar versões do Flutter"
    printf "%b\n" "${GREEN}3.${NC} Criar novo ambiente"
    printf "%b\n" "${GREEN}4.${NC} Usar ambiente"
    printf "%b\n" "${GREEN}5.${NC} Atualizar Puro"
    printf "%b\n" "${RED}0.${NC} Sair"
    echo
    printf "Digite sua escolha [0-5]: "
}


# Usar versão global do Flutter
use_flutter_global() {
    show_header
    printf "%b\n" "${BLUE}Selecione a versão do Flutter para usar globalmente:${NC}"
    # Coleta aliases principais (stable, beta, master) se existirem
    aliases=()
    alias_labels=()
    for alias in stable beta master; do
        if puro ls | grep -qE "^[[:space:]]*$alias[[:space:]]"; then
            aliases+=("$alias")
            alias_labels+=("${YELLOW}$alias [canal]${NC}")
        fi
    done
    # Coleta todas as versões disponíveis
    versions=()
    versions_display=()
    installed=()
    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        if [[ "$clean" =~ ^[[:space:]]*Flutter[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+[^ ]*) ]]; then
            versao=$(echo "$clean" | awk '{for(i=1;i<=NF;i++) if($i=="Flutter") print $(i+1)}')
            versions+=("$versao")
        fi
    done <<< "$(puro ls-versions)"
    # Descobre qual versão é a stable
    stable_version=""
    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        if [[ "$clean" =~ ^[[:space:]]*stable[[:space:]] ]]; then
            stable_version=$(echo "$clean" | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?' | head -n1 | tr -d '(')
            break
        fi
    done <<< "$(puro ls)"
    # Coleta todos ambientes instalados (nomeados e numéricos)
    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        nome=$(echo "$clean" | awk '{print $1}')
        versao=$(echo "$clean" | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?' | head -n1 | tr -d '(')
        if [ -z "$versao" ]; then
            versao=$(echo "$clean" | awk '{for(i=2;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+/) {print $i; break}}')
        fi
        if [ -n "$versao" ]; then
            installed+=("$versao")
        fi
    done <<< "$(puro ls)"
    idx=1
    for i in "${!aliases[@]}"; do
        printf "%b\n" "  $idx) ${alias_labels[$i]}"
        idx=$((idx+1))
    done
    for i in "${!versions[@]}"; do
        label="${versions[$i]}"
        if [ -n "$stable_version" ] && [ "${versions[$i]}" = "$stable_version" ]; then
            label+=" ${YELLOW}[stable]${NC}"
        fi
        if printf '%s\n' "${installed[@]}" | grep -Fxq "${versions[$i]}"; then
            printf "%b\n" "  $idx) ${GREEN}$label [instalado]${NC}"
        else
            printf "%b\n" "  $idx) ${YELLOW}$label${NC}"
        fi
        idx=$((idx+1))
    done
    printf "%b\n" "  0) Voltar"
    total_opts=$(( ${#aliases[@]} + ${#versions[@]} ))
    while true; do
        read -p "Digite o número da versão desejada: " escolha
        if [[ "$escolha" =~ ^[0-9]+$ ]]; then
            if [ "$escolha" -eq 0 ]; then
                return
            elif [ "$escolha" -ge 1 ] && [ "$escolha" -le $total_opts ]; then
                if [ "$escolha" -le ${#aliases[@]} ]; then
                    alias_sel="${aliases[$((escolha-1))]}"
                    printf "%b\n" "${GREEN}Definindo Flutter $alias_sel como global...${NC}"
                    puro use "$alias_sel" --global
                else
                    idx_vers=$((escolha-#aliases[@]-1))
                    versao="${versions[$idx_vers]}"
                    printf "%b\n" "${GREEN}Definindo Flutter $versao como global...${NC}"
                    if printf '%s\n' "${installed[@]}" | grep -Fxq "$versao"; then
                        printf "%b\n" "${YELLOW}Ambiente já existe. Apenas definindo como global...${NC}"
                    else
                        printf "%b\n" "${YELLOW}Ambiente não existe, criando...${NC}"
                        puro create "$versao" "$versao"
                    fi
                    puro use "$versao" --global
                fi
                break
            else
                printf "%b\n" "${RED}Opção inválida.${NC}"
            fi
        else
            printf "%b\n" "${RED}Digite apenas números.${NC}"
        fi
    done
    # Recarrega o ambiente automaticamente
    if [ -f "$HOME/.puro/env" ]; then
        printf "%b\n" "${CYAN}Recarregando ambiente do Flutter (source ~/.puro/env)...${NC}"
        # shellcheck source=/dev/null
        source "$HOME/.puro/env"
        printf "%b\n" "${GREEN}Ambiente recarregado!${NC}"
    else
        printf "%b\n" "${YELLOW}Arquivo ~/.puro/env não encontrado. Abra um novo terminal se necessário.${NC}"
    fi
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Usar versão do Flutter neste projeto
use_flutter_project() {
    show_header
    printf "%b\n" "${BLUE}Selecione a versão do Flutter para este projeto:${NC}"
    # Coleta aliases principais (stable, beta, master) se existirem
    aliases=()
    alias_labels=()
    for alias in stable beta master; do
        if puro ls | grep -qE "^[[:space:]]*$alias[[:space:]]"; then
            aliases+=("$alias")
            alias_labels+=("${YELLOW}$alias [canal]${NC}")
        fi
    done
    versions=()
    versions_display=()
    installed=()
    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        if [[ "$clean" =~ ^[[:space:]]*Flutter[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+[^ ]*) ]]; then
            versao=$(echo "$clean" | awk '{for(i=1;i<=NF;i++) if($i=="Flutter") print $(i+1)}')
            versions+=("$versao")
        fi
    done <<< "$(puro ls-versions)"
    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        nome=$(echo "$clean" | awk '{print $1}')
        versao=$(echo "$clean" | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?' | head -n1 | tr -d '(')
        if [ -z "$versao" ]; then
            versao=$(echo "$clean" | awk '{for(i=2;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+/) {print $i; break}}')
        fi
        if [ -n "$versao" ]; then
            installed+=("$versao")
        fi
    done <<< "$(puro ls)"
    idx=1
    for i in "${!aliases[@]}"; do
        printf "%b\n" "  $idx) ${alias_labels[$i]}"
        idx=$((idx+1))
    done
    for i in "${!versions[@]}"; do
        if printf '%s\n' "${installed[@]}" | grep -Fxq "${versions[$i]}"; then
            printf "%b\n" "  $idx) ${GREEN}${versions[$i]} [instalado]${NC}"
        else
            printf "%b\n" "  $idx) ${YELLOW}${versions[$i]}${NC}"
        fi
        idx=$((idx+1))
    done
    printf "%b\n" "  0) Voltar"
    total_opts=$(( ${#aliases[@]} + ${#versions[@]} ))
    while true; do
        read -p "Digite o número da versão desejada: " escolha
        if [[ "$escolha" =~ ^[0-9]+$ ]]; then
            if [ "$escolha" -eq 0 ]; then
                return
            elif [ "$escolha" -ge 1 ] && [ "$escolha" -le $total_opts ]; then
                if [ "$escolha" -le ${#aliases[@]} ]; then
                    alias_sel="${aliases[$((escolha-1))]}"
                    printf "%b\n" "${GREEN}Aplicando Flutter $alias_sel neste projeto...${NC}"
                    puro upgrade "$alias_sel" --project=.
                else
                    idx_vers=$((escolha-#aliases[@]-1))
                    versao="${versions[$idx_vers]}"
                    printf "%b\n" "${GREEN}Aplicando Flutter $versao neste projeto...${NC}"
                    puro upgrade "$versao" --project=.
                fi
                break
            else
                printf "%b\n" "${RED}Opção inválida.${NC}"
            fi
        else
            printf "%b\n" "${RED}Digite apenas números.${NC}"
        fi
    done
    # Recarrega o ambiente automaticamente
    if [ -f "$HOME/.puro/env" ]; then
        printf "%b\n" "${CYAN}Recarregando ambiente do Flutter (source ~/.puro/env)...${NC}"
        # shellcheck source=/dev/null
        source "$HOME/.puro/env"
        printf "%b\n" "${GREEN}Ambiente recarregado!${NC}"
    else
        printf "%b\n" "${YELLOW}Arquivo ~/.puro/env não encontrado. Abra um novo terminal se necessário.${NC}"
    fi
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Instalar nova versão do Flutter
install_flutter_version() {
    show_header
    printf "%b\n" "${BLUE}Digite a versão do Flutter que deseja instalar (ex: 3.19.3):${NC}"
    read -p "Versão: " versao
    if [ -z "$versao" ]; then
        printf "%b\n" "${RED}Versão não informada.${NC}"
    else
        printf "%b\n" "${GREEN}Instalando Flutter $versao...${NC}"
        puro upgrade "$versao"
    fi
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Remover versão do Flutter
remove_flutter_version() {
    show_header
    printf "%b\n" "${BLUE}Selecione o ambiente do Flutter para remover:${NC}"
    menu_items=()
    menu_names=()
    # Parse puro ls para listar ambientes igual ao output real, ignorando linhas de dica/uso
    # Descobre qual ambiente é o stable (nome exato ou alias)
    stable_env=""
    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        if [[ "$clean" =~ ^[[:space:]]*stable[[:space:]] ]]; then
            stable_env="stable"
            break
        fi
    done <<< "$(puro ls)"

    while IFS= read -r linha; do
        clean=$(echo "$linha" | sed 's/\x1b\[[0-9;]*m//g')
        # Ignora linhas vazias e linhas de dica/uso (começam com 'Use' ou espaços + 'Use')
        if [[ -z "$clean" ]] || [[ "$clean" =~ ^[[:space:]]*Use ]]; then
            continue
        fi
        # Ambiente atual (linha começa com ~)
        if [[ "$clean" =~ ^[[:space:]]*~ ]]; then
            nome=$(echo "$clean" | awk '{print $2}')
            info=$(echo "$clean" | sed -E 's/^[^\(]*\(([^)]*)\).*/\1/')
            label="~ $nome ($info)"
            if [[ "$nome" == "$stable_env" ]]; then
                label+=" ${YELLOW}[stable]${NC}"
            fi
            menu_items+=("$label")
            menu_names+=("$nome")
        # Ambiente instalado (linha começa com espaço + nome)
        elif [[ "$clean" =~ ^[[:space:]]+[a-zA-Z0-9._-]+ ]]; then
            nome=$(echo "$clean" | awk '{print $1}')
            info=$(echo "$clean" | sed -E 's/^[^\(]*\(([^)]*)\).*/\1/')
            if [[ "$info" != "not installed" && -n "$info" ]]; then
                label="$nome ($info)"
                if [[ "$nome" == "$stable_env" ]]; then
                    label+=" ${YELLOW}[stable]${NC}"
                fi
                menu_items+=("$label")
                menu_names+=("$nome")
            fi
        fi
    done <<< "$(puro ls)"
    if [ ${#menu_items[@]} -eq 0 ]; then
        printf "%b\n" "${RED}Nenhum ambiente encontrado para remoção.${NC}"
        read -p "Pressione Enter para voltar..."
        return
    fi
    for i in "${!menu_items[@]}"; do
        n=$((i+1))
        printf "%b\n" "  $n) ${GREEN}${menu_items[$i]}${NC}"
    done
    printf "%b\n" "  0) Voltar"
    while true; do
        read -p "Digite o número do ambiente para remover: " escolha
        if [[ "$escolha" =~ ^[0-9]+$ ]]; then
            if [ "$escolha" -eq 0 ]; then
                break
            elif [ "$escolha" -ge 1 ] && [ "$escolha" -le ${#menu_names[@]} ]; then
                env_name="${menu_names[$((escolha-1))]}"
                printf "%b\n" "${GREEN}Removendo ambiente '$env_name'...${NC}"
                rm_output=$(puro rm "$env_name" 2>&1)
                if [ $? -eq 0 ]; then
                    printf "%b\n" "${GREEN}Ambiente removido com sucesso!${NC}"
                    read -p "Pressione Enter para voltar..."
                    remove_flutter_version
                    return
                else
                    # Detecta se erro é ambiente em uso
                    if echo "$rm_output" | grep -qE 'is currently used by the following projects:'; then
                        printf "%b\n" "${YELLOW}$rm_output${NC}"
                        read -p "Deseja forçar a remoção mesmo assim? (s/N): " confirm
                        if [[ "$confirm" =~ ^[sS]$ ]]; then
                            if puro rm "$env_name" -f; then
                                printf "%b\n" "${GREEN}Ambiente removido com sucesso!${NC}"
                                read -p "Pressione Enter para voltar..."
                                remove_flutter_version
                                return
                            else
                                printf "%b\n" "${RED}Erro ao remover ambiente mesmo forçando.${NC}"
                                read -p "Pressione Enter para voltar..."
                                remove_flutter_version
                                return
                            fi
                        else
                            printf "%b\n" "${YELLOW}Remoção cancelada.${NC}"
                            read -p "Pressione Enter para voltar..."
                            remove_flutter_version
                            return
                        fi
                    else
                        printf "%b\n" "${RED}Erro ao remover ambiente.${NC}"
                        echo "$rm_output"
                        read -p "Pressione Enter para voltar..."
                        remove_flutter_version
                        return
                    fi
                fi
            else
                printf "%b\n" "${RED}Opção inválida.${NC}"
            fi
        else
            printf "%b\n" "${RED}Digite apenas números.${NC}"
        fi
    done
}

# Atualizar Puro
upgrade_puro() {
    show_header
    printf "%b\n" "${BLUE}Atualizando Puro...${NC}"
    puro upgrade-puro
    echo
    printf "%b\n" "${GREEN}Puro atualizado!${NC}"
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Limpar caches
clean_caches() {
    show_header
    printf "%b\n" "${BLUE}Limpando caches não utilizados...${NC}"
    puro gc
    printf "%b\n" "${GREEN}Caches limpos!${NC}"
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Menu principal
main() {
    while true; do
        show_header
        printf "%b\n" "${BLUE}Selecione uma opção:${NC}"
        printf "%b\n" "   1) 🌍 ${GREEN}Usar versão do Flutter Globalmente${NC}"
        printf "%b\n" "   2) 📁 ${GREEN}Usar versão do Flutter apenas neste projeto${NC}"
        printf "%b\n" "   3) 🗑️  ${GREEN}Remover versão do Flutter${NC}"
        printf "%b\n" "   4) ⬆️  ${GREEN}Atualizar Puro${NC}"
        printf "%b\n" "   5) 🧹 ${GREEN}Limpar caches${NC}"
        printf "%b\n" "   6) 🛠️  ${YELLOW}Gerenciar Puro (instalar/desinstalar)${NC}"
        printf "%b\n" "   0) 🚪 ${RED}Sair${NC}"
        while true; do
            read -p "Digite o número da opção desejada: " opt
            case $opt in
                1) use_flutter_global; break ;;
                2) use_flutter_project; break ;;
                3) remove_flutter_version; break ;;
                4) upgrade_puro; break ;;
                5) clean_caches; break ;;
                6)
                    while true; do
                        show_header
                        printf "%b\n" "${YELLOW}Gerenciar Puro:${NC}"
                        printf "%b\n" "  1) Instalar ou atualizar Puro"
                        printf "%b\n" "  2) Desinstalar Puro"
                        printf "%b\n" "  0) Voltar"
                        read -p "Digite o número da opção desejada: " puro_opt
                        case $puro_opt in
                            1) install_puro; break ;;
                            2) uninstall_puro; break ;;
                            0) break ;;
                            *) printf "%b\n" "${RED}Opção inválida. Digite 0, 1 ou 2.${NC}" ;;
                        esac
                    done
                    break
                    ;;
                0) printf "%b\n" "${RED}Saindo...${NC}"; exit 0 ;;
                *) printf "%b\n" "${RED}Opção inválida. Digite um número de 0 a 6.${NC}" ;;
            esac
        done
    done
}

trap 'echo -e "\033[1;31mPara encerrar o script, pressione Ctrl + C no terminal.\033[0m"' EXIT

main