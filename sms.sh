#!/bin/bash

# SCRCPY Manager
# Este script facilita a conexão e o gerenciamento de dispositivos Android via scrcpy e adb.

# Configurações e flags para debug
DEBUG=true
TIMEOUT=10

# Cores para o menu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações persistentes do scrcpy (salvas no próprio script)
# SCRCPY_CONFIG_START - NÃO REMOVA ESTA LINHA
SCRCPY_ALWAYS_ON_TOP="true"
SCRCPY_FULLSCREEN=""
SCRCPY_SHOW_TOUCHES=""
SCRCPY_STAY_AWAKE="true"
SCRCPY_TURN_SCREEN_OFF="true"
SCRCPY_NO_CONTROL=""
SCRCPY_MAX_SIZE=""
SCRCPY_MAX_FPS=""
SCRCPY_VIDEO_BIT_RATE=""
SCRCPY_AUDIO_BIT_RATE=""
SCRCPY_VIDEO_CODEC=""
SCRCPY_AUDIO_CODEC=""
SCRCPY_AUDIO_SOURCE=""
SCRCPY_DISPLAY_ORIENTATION=""
SCRCPY_RECORD_ORIENTATION=""
SCRCPY_WINDOW_TITLE=""
SCRCPY_DISABLE_SCREENSAVER="true"
SCRCPY_NO_AUDIO="true"
SCRCPY_NO_VIDEO=""
SCRCPY_NO_CLIPBOARD_AUTOSYNC=""
SCRCPY_PRINT_FPS=""
SCRCPY_POWER_OFF_ON_CLOSE=""
SCRCPY_WINDOW_BORDERLESS=""
SCRCPY_CROP=""
SCRCPY_VERBOSITY=""
SCRCPY_CUSTOM_OPTIONS=""
# SCRCPY_CONFIG_END - NÃO REMOVA ESTA LINHA

# Função para log com timestamp
log() {
    if [ "$DEBUG" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
}

# Função para verificar versão do scrcpy
check_scrcpy_version() {
    local version=$(scrcpy --version 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+')
    log "Versão do scrcpy detectada: $version"
    echo "$version"
}

# Função para exibir o cabeçalho
show_header() {
    clear
    printf "%b\n" "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "%b\n" "${CYAN}║                    ${YELLOW}SCRCPY Manager${CYAN}                            ║${NC}"
    printf "%b\n" "${CYAN}║              ${GREEN}Conecte seu Android via WiFi no Mac${CYAN}             ║${NC}"
    printf "%b\n" "${CYAN}║  ${RED}Para encerrar este script, pressione Ctrl + C no terminal.${CYAN}  ║${NC}"
    printf "%b\n" "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Função para exibir o menu principal
show_main_menu() {
    # Aviso sobre VPN logo após o cabeçalho
    printf "%b\n" "${YELLOW}ATENÇÃO:${NC} Se você estiver conectado a uma VPN, a conexão provavelmente irá falhar. Desconecte da VPN antes de usar este script."
    echo
    printf "%b\n" "${BLUE}Selecione uma categoria:${NC}"
    echo
    printf "%b\n" "${GREEN}1.${NC} 🔗 Conectar Dispositivo"
    printf "%b\n" "${GREEN}2.${NC} 🔧 Diagnóstico e Troubleshooting"
    printf "%b\n" "${GREEN}3.${NC} 📱 Gerenciar Dispositivos"
    printf "%b\n" "${GREEN}4.${NC} ⚙️  Configurações"
    printf "%b\n" "${RED}0.${NC} 🚪 Sair"
    echo
    printf "Digite sua escolha [0-4]: "
}

# Função para submenu de conexão
show_connection_menu() {
    printf "%b\n" "${BLUE}🔗 Opções de Conexão:${NC}"
    echo
    printf "%b\n" "${GREEN}1.${NC} Conectar via WiFi (Padrão - 2M, 60fps)"
    printf "%b\n" "${GREEN}2.${NC} Conectar via WiFi (Baixa qualidade - 1M, 30fps)"
    printf "%b\n" "${GREEN}3.${NC} Conectar via WiFi (Alta qualidade - 8M, 60fps)"
    printf "%b\n" "${GREEN}4.${NC} Conectar via WiFi (Qualidade personalizada)"
    printf "%b\n" "${GREEN}5.${NC} Conectar via USB (sem WiFi)"
    printf "%b\n" "${YELLOW}6.${NC} Soluções rápidas para problemas de WiFi"
    printf "%b\n" "${BLUE}0.${NC} ← Voltar ao menu principal"
    echo
    echo -n "Digite sua escolha [0-6]: "
}

# Função para submenu de diagnóstico
show_diagnostic_menu() {
    printf "%b\n" "${BLUE}🔧 Diagnóstico e Troubleshooting:${NC}"
    echo
    printf "%b\n" "${GREEN}1.${NC} Diagnóstico completo do sistema"
    printf "%b\n" "${GREEN}2.${NC} Troubleshooting avançado"
    printf "%b\n" "${GREEN}3.${NC} Testar conectividade WiFi"
    printf "%b\n" "${YELLOW}4.${NC} Ver logs de erro detalhados"
    printf "%b\n" "${BLUE}0.${NC} ← Voltar ao menu principal"
    echo
    echo -n "Digite sua escolha [0-4]: "
}

# Função para submenu de dispositivos
show_device_menu() {
    printf "%b\n" "${BLUE}📱 Gerenciar Dispositivos:${NC}"
    echo
    printf "%b\n" "${GREEN}1.${NC} Listar todos os dispositivos conectados"
    printf "%b\n" "${GREEN}2.${NC} Desconectar dispositivos WiFi"
    printf "%b\n" "${GREEN}3.${NC} Reconectar dispositivo WiFi"
    printf "%b\n" "${YELLOW}4.${NC} Resetar todas as conexões ADB"
    printf "%b\n" "${BLUE}0.${NC} ← Voltar ao menu principal"
    echo
    echo -n "Digite sua escolha [0-4]: "
}

# Função para submenu de configurações
show_settings_menu() {
    printf "%b\n" "${BLUE}⚙️  Configurações:${NC}"
    echo
    printf "%b\n" "${GREEN}1.${NC} Ativar/Desativar logs de debug"
    printf "%b\n" "${GREEN}2.${NC} Configurar opções do scrcpy"
    printf "%b\n" "${GREEN}3.${NC} Ver configurações atuais do scrcpy"
    printf "%b\n" "${GREEN}4.${NC} Configurar timeout de conexão"
    printf "%b\n" "${GREEN}5.${NC} Verificar/Instalar dependências"
    printf "%b\n" "${YELLOW}6.${NC} Resetar configurações scrcpy para padrão"
    printf "%b\n" "${GREEN}7.${NC} Mostrar informações do sistema"
    printf "%b\n" "${BLUE}0.${NC} ← Voltar ao menu principal"
    echo
    echo -n "Digite sua escolha [0-7]: "
}

# Função para conectar via USB
connect_usb() {
    show_header
    printf "%b\n" "${YELLOW}=== CONEXÃO VIA USB ===${NC}"
    echo

    USB_DEVICES=$(adb devices | sed 1d | awk '$2=="device" {print $1}' | grep -v '^$' | grep -v '5555')
    if [ -z "$USB_DEVICES" ]; then
        printf "%b\n" "${RED}Nenhum dispositivo USB conectado${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    DEVICE_ID=$(echo "$USB_DEVICES" | head -n 1)
    printf "%b\n" "${GREEN}Conectando via USB ao dispositivo: $DEVICE_ID${NC}"
    echo

    # Configurar opções básicas para USB
    SCRCPY_VERSION=$(check_scrcpy_version)
    SCRCPY_OPTIONS="--stay-awake"

    if [[ $SCRCPY_VERSION == "3."* ]]; then
        SCRCPY_OPTIONS="$SCRCPY_OPTIONS --always-on-top"
    else
        SCRCPY_OPTIONS="$SCRCPY_OPTIONS --always-on-top"
    fi

    echo "Iniciando scrcpy via USB..."
    echo "Comando: scrcpy $SCRCPY_OPTIONS -s $DEVICE_ID"
    echo

    if scrcpy $SCRCPY_OPTIONS -s $DEVICE_ID; then
        printf "%b\n" "${GREEN}Conexão USB bem-sucedida!${NC}"
    else
        printf "%b\n" "${RED}Erro na conexão USB${NC}"
        echo "Verifique se:"
        echo "  1. Depuração USB está ativada"
        echo "  2. Você autorizou a conexão no celular"
        echo "  3. O cabo USB está funcionando"
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para reconectar dispositivo WiFi
reconnect_wifi() {
    show_header
    printf "%b\n" "${YELLOW}=== RECONECTAR DISPOSITIVO WIFI ===${NC}"
    echo

    # Primeiro verificar se há dispositivos WiFi conectados
    WIFI_DEVICES=$(adb devices | grep '5555' | awk '{print $1}')
    if [ ! -z "$WIFI_DEVICES" ]; then
        printf "%b\n" "${BLUE}Dispositivos WiFi encontrados:${NC}"
        echo "$WIFI_DEVICES"
        echo
        echo "Desconectando dispositivos WiFi existentes..."
        for DEVICE in $WIFI_DEVICES; do
            adb disconnect $DEVICE
        done
        printf "%b\n" "${GREEN}Dispositivos WiFi desconectados${NC}"
        echo
    fi

    # Agora tentar reconectar
    USB_DEVICES=$(adb devices | sed 1d | awk '$2=="device" {print $1}' | grep -v '^$' | grep -v '5555')
    if [ -z "$USB_DEVICES" ]; then
        printf "%b\n" "${RED}Nenhum dispositivo USB conectado para reconectar via WiFi${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    DEVICE_ID=$(echo "$USB_DEVICES" | head -n 1)
    printf "%b\n" "${BLUE}Reconectando dispositivo: $DEVICE_ID${NC}"

    # Obter IP
    DEVICE_IP=$(adb -s $DEVICE_ID shell ip route 2>/dev/null | awk '/wlan0/ {print $9}' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n 1 | tr -d '\r\n')

    if [ -z "$DEVICE_IP" ]; then
        printf "%b\n" "${RED}Não foi possível obter IP do dispositivo${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    echo "IP encontrado: $DEVICE_IP"
    echo "Configurando modo TCP..."

    # Configurar TCP e conectar
    adb -s $DEVICE_ID tcpip 5555
    sleep 3

    echo "Conectando via WiFi..."
    if adb connect $DEVICE_IP:5555; then
        printf "%b\n" "${GREEN}Reconexão WiFi bem-sucedida!${NC}"
        echo
        printf "%b\n" "${BLUE}Dispositivos conectados:${NC}"
        adb devices
    else
        printf "%b\n" "${RED}Falha na reconexão WiFi${NC}"
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para resetar conexões ADB
reset_adb_connections() {
    show_header
    printf "%b\n" "${YELLOW}=== RESETAR CONEXÕES ADB ===${NC}"
    echo

    echo "Desconectando todos os dispositivos WiFi..."
    WIFI_DEVICES=$(adb devices | grep '5555' | awk '{print $1}')
    if [ ! -z "$WIFI_DEVICES" ]; then
        for DEVICE in $WIFI_DEVICES; do
            echo "Desconectando $DEVICE..."
            adb disconnect $DEVICE
        done
    fi

    echo "Parando servidor ADB..."
    adb kill-server
    sleep 2

    echo "Iniciando servidor ADB..."
    adb start-server
    sleep 2

    printf "%b\n" "${GREEN}Reset completo do ADB realizado!${NC}"
    echo
    printf "%b\n" "${BLUE}Dispositivos atualmente conectados:${NC}"
    adb devices -l

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para mostrar logs de erro
show_error_logs() {
    show_header
    printf "%b\n" "${YELLOW}=== LOGS DE ERRO DETALHADOS ===${NC}"
    echo

    printf "%b\n" "${BLUE}Verificando logs disponíveis...${NC}"
    echo

    # Verificar se há logs do scrcpy
    if [ -f "/tmp/scrcpy_test.log" ]; then
        printf "%b\n" "${GREEN}Log do último teste scrcpy encontrado:${NC}"
        echo "----------------------------------------"
        cat /tmp/scrcpy_test.log
        echo "----------------------------------------"
        echo
    fi

    if [ -f "/tmp/scrcpy_quick_test.log" ]; then
        printf "%b\n" "${GREEN}Log do teste rápido encontrado:${NC}"
        echo "----------------------------------------"
        cat /tmp/scrcpy_quick_test.log
        echo "----------------------------------------"
        echo
    fi

    # Verificar logs do sistema
    printf "%b\n" "${BLUE}Últimas mensagens do sistema relacionadas ao ADB:${NC}"
    echo "------------------------------------------------"
    log show --predicate 'process == "adb"' --info --last 10m 2>/dev/null || echo "Nenhum log do sistema disponível"

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para configurar qualidade padrão
configure_default_quality() {
    show_header
    printf "%b\n" "${YELLOW}=== CONFIGURAR QUALIDADE PADRÃO ===${NC}"
    echo

    printf "%b\n" "${BLUE}Selecione a qualidade padrão:${NC}"
    echo
    printf "%b\n" "${GREEN}1.${NC} Baixa (1M bitrate, 30fps) - Para redes lentas"
    printf "%b\n" "${GREEN}2.${NC} Média (2M bitrate, 60fps) - Recomendado"
    printf "%b\n" "${GREEN}3.${NC} Alta (8M bitrate, 60fps) - Para redes rápidas"
    printf "%b\n" "${GREEN}4.${NC} Personalizada"
    echo
    echo -n "Digite sua escolha [1-4]: "
    read quality_choice

    case $quality_choice in
        1)
            DEFAULT_BITRATE="1M"
            DEFAULT_FPS="30"
            printf "%b\n" "${GREEN}Qualidade baixa configurada como padrão${NC}"
            ;;
        2)
            DEFAULT_BITRATE="2M"
            DEFAULT_FPS="60"
            printf "%b\n" "${GREEN}Qualidade média configurada como padrão${NC}"
            ;;
        3)
            DEFAULT_BITRATE="8M"
            DEFAULT_FPS="60"
            printf "%b\n" "${GREEN}Qualidade alta configurada como padrão${NC}"
            ;;
        4)
            echo -n "Digite o bitrate (ex: 4M): "
            read DEFAULT_BITRATE
            echo -n "Digite o FPS (ex: 45): "
            read DEFAULT_FPS
            printf "%b\n" "${GREEN}Qualidade personalizada configurada${NC}"
            ;;
        *)
            printf "%b\n" "${RED}Opção inválida${NC}"
            ;;
    esac

    echo
    printf "%b\n" "${BLUE}Configuração atual:${NC}"
    echo "Bitrate: ${DEFAULT_BITRATE:-2M}"
    echo "FPS: ${DEFAULT_FPS:-60}"

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para mostrar informações do sistema
show_system_info() {
    show_header
    printf "%b\n" "${YELLOW}=== INFORMAÇÕES DO SISTEMA ===${NC}"
    echo

    printf "%b\n" "${BLUE}Sistema Operacional:${NC}"
    echo "$(sw_vers)"
    echo

    printf "%b\n" "${BLUE}Versões das Ferramentas:${NC}"
    if command -v scrcpy &> /dev/null; then
        echo "scrcpy: $(scrcpy --version | head -n 1)"
    else
        printf "%b\n" "${RED}scrcpy: Não instalado${NC}"
    fi

    if command -v adb &> /dev/null; then
        echo "adb: $(adb --version | head -n 1)"
    else
        printf "%b\n" "${RED}adb: Não instalado${NC}"
    fi
    echo

    printf "%b\n" "${BLUE}Configurações Atuais do Script:${NC}"
    echo "Debug: ${DEBUG}"
    echo "Timeout: ${TIMEOUT}s"
    echo "Bitrate padrão: ${DEFAULT_BITRATE:-2M}"
    echo "FPS padrão: ${DEFAULT_FPS:-60}"
    echo

    printf "%b\n" "${BLUE}Rede:${NC}"
    echo "IP do Mac: $(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}')"
    echo

    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função de diagnóstico
run_diagnostics() {
    show_header
    printf "%b\n" "${YELLOW}=== DIAGNÓSTICO DO SISTEMA ===${NC}"
    echo

    # Verificar versões
    printf "%b\n" "${BLUE}1. VERSÕES INSTALADAS:${NC}"
    echo "----------------------"
    if command -v scrcpy &> /dev/null; then
        printf "%b\n" "✓ scrcpy: $(scrcpy --version | head -n 1)"
    else
        printf "%b\n" "${RED}✗ scrcpy não encontrado${NC}"
    fi

    if command -v adb &> /dev/null; then
        printf "%b\n" "✓ adb: $(adb --version | head -n 1)"
    else
        printf "%b\n" "${RED}✗ adb não encontrado${NC}"
    fi
    echo

    # Verificar dispositivos
    printf "%b\n" "${BLUE}2. DISPOSITIVOS CONECTADOS:${NC}"
    echo "---------------------------"
    adb devices -l
    echo

    # Verificar processos
    printf "%b\n" "${BLUE}3. PROCESSOS RELACIONADOS:${NC}"
    echo "--------------------------"
    echo "Processos adb:"
    ps aux | grep adb | grep -v grep || echo "Nenhum processo adb encontrado"
    echo
    echo "Processos scrcpy:"
    ps aux | grep scrcpy | grep -v grep || echo "Nenhum processo scrcpy encontrado"
    echo

    # Verificar portas
    printf "%b\n" "${BLUE}4. PORTAS EM USO:${NC}"
    echo "----------------"
    echo "Porta 5555 (adb WiFi):"
    lsof -i :5555 2>/dev/null || echo "Porta 5555 livre"
    echo

    # Verificar conectividade de rede
    printf "%b\n" "${BLUE}5. TESTE DE CONECTIVIDADE:${NC}"
    echo "--------------------------"
    USB_DEVICES=$(adb devices | sed 1d | awk '$2=="device" {print $1}' | grep -v '^$' | grep -v '5555')

    if [ ! -z "$USB_DEVICES" ]; then
        DEVICE_COUNT=$(echo "$USB_DEVICES" | wc -l | xargs)
        if [ "$DEVICE_COUNT" -eq 1 ]; then
            DEVICE_ID=$USB_DEVICES
            echo "Dispositivo USB: $DEVICE_ID"

            # Tentar obter IP
            DEVICE_IP=$(adb -s $DEVICE_ID shell ip route 2>/dev/null | awk '/wlan0/ {print $9}' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n 1 | tr -d '\r\n')

            if [ ! -z "$DEVICE_IP" ]; then
                echo "IP do dispositivo: $DEVICE_IP"
                echo "Testando conectividade..."
                if ping -c 1 -W 3000 $DEVICE_IP &>/dev/null; then
                    printf "%b\n" "${GREEN}✓ Ping para $DEVICE_IP bem-sucedido${NC}"
                else
                    printf "%b\n" "${RED}✗ Ping para $DEVICE_IP falhou${NC}"
                fi
            else
                printf "%b\n" "${RED}✗ Não foi possível obter IP do dispositivo${NC}"
            fi
        else
            echo "Múltiplos dispositivos encontrados. Execute a conexão para selecionar."
        fi
    else
        printf "%b\n" "${RED}✗ Nenhum dispositivo USB conectado${NC}"
    fi
    echo

    # Sugestões
    printf "%b\n" "${BLUE}6. SUGESTÕES DE SOLUÇÃO:${NC}"
    echo "------------------------"
    echo "Se houver problemas:"
    echo "  1. Reinicie o servidor adb: adb kill-server && adb start-server"
    echo "  2. Verifique se o dispositivo está na mesma rede WiFi"
    echo "  3. Certifique-se de que a depuração USB está habilitada"
    echo "  4. Tente executar: scrcpy --verbosity=debug"
    echo "  5. Para scrcpy 3.x, algumas opções podem ter mudado"
    echo "  6. Verifique se não há firewall bloqueando a porta 5555"
    echo

    # Teste rápido do scrcpy
    printf "%b\n" "${BLUE}7. TESTE RÁPIDO DO SCRCPY:${NC}"
    echo "-------------------------"
    if [ ! -z "$USB_DEVICES" ] && [ "$DEVICE_COUNT" -eq 1 ]; then
        echo "Executando teste rápido com dispositivo USB..."
        scrcpy -s $DEVICE_ID --no-display --verbosity=debug &>/tmp/scrcpy_quick_test.log &
        TEST_PID=$!
        sleep 8
        kill $TEST_PID 2>/dev/null
        wait $TEST_PID 2>/dev/null

        if grep -q "Device connected" /tmp/scrcpy_quick_test.log 2>/dev/null; then
            printf "%b\n" "${GREEN}✓ scrcpy consegue se conectar ao dispositivo USB${NC}"
        else
            printf "%b\n" "${RED}✗ scrcpy falhou ao conectar com dispositivo USB${NC}"
        fi
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar ao menu principal...${NC}"
    read
}

# Função para soluções rápidas de problemas WiFi
wifi_quick_fixes() {
    show_header
    printf "%b\n" "${YELLOW}=== SOLUÇÕES RÁPIDAS PARA PROBLEMAS WIFI ===${NC}"
    echo

    USB_DEVICES=$(adb devices | sed 1d | awk '$2=="device" {print $1}' | grep -v '^$' | grep -v '5555')
    if [ -z "$USB_DEVICES" ]; then
        printf "%b\n" "${RED}Nenhum dispositivo USB conectado${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    DEVICE_ID=$(echo "$USB_DEVICES" | head -n 1)
    printf "%b\n" "${BLUE}Dispositivo encontrado: $DEVICE_ID${NC}"
    echo

    printf "%b\n" "${BLUE}Aplicando soluções rápidas:${NC}"
    echo

    # Solução 1: Reiniciar servidor ADB
    echo "1. Reiniciando servidor ADB..."
    adb kill-server
    sleep 2
    adb start-server
    sleep 2
    printf "%b\n" "   ${GREEN}✓ Servidor ADB reiniciado${NC}"

    # Solução 2: Reconfigurar modo TCP múltiplas vezes
    echo "2. Configurando modo TCP (método robusto)..."
    for i in {1..3}; do
        echo "   Tentativa $i..."
        adb -s $DEVICE_ID tcpip 5555 >/dev/null 2>&1
        sleep 5
    done
    printf "%b\n" "   ${GREEN}✓ Modo TCP configurado${NC}"

    # Solução 3: Obter IP atual
    echo "3. Obtendo IP atual do dispositivo..."
    DEVICE_IP=$(get_device_ip "$DEVICE_ID")
    if [ ! -z "$DEVICE_IP" ]; then
        printf "%b\n" "   ${GREEN}✓ IP encontrado: $DEVICE_IP${NC}"
    else
        printf "%b\n" "   ${RED}✗ Não foi possível obter IP${NC}"
        printf "%b\n" "   ${YELLOW}Verifique se o WiFi está ativo no celular${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    # Solução 4: Tentar conectar com paciência
    echo "4. Tentando conectar via WiFi..."
    CONNECTED=false

    for attempt in {1..5}; do
        echo "   Tentativa $attempt de 5..."

        # Usar diferentes métodos de conexão
        if [ $attempt -le 2 ]; then
            # Tentativas normais
            if adb connect $DEVICE_IP:5555 2>/dev/null | grep -q "connected"; then
                CONNECTED=true
                break
            fi
        else
            # Tentativas com reconfiguração
            echo "   Reconfigurando TCP..."
            adb -s $DEVICE_ID tcpip 5555 >/dev/null 2>&1
            sleep 3
            if adb connect $DEVICE_IP:5555 2>/dev/null | grep -q "connected"; then
                CONNECTED=true
                break
            fi
        fi

        sleep 5
    done

    if [ "$CONNECTED" = true ]; then
        printf "%b\n" "   ${GREEN}✓ Conectado via WiFi com sucesso!${NC}"
        echo
        printf "%b\n" "${BLUE}Dispositivos conectados:${NC}"
        adb devices
        echo
        printf "%b\n" "${GREEN}Agora você pode usar:${NC}"
        echo "  scrcpy -s $DEVICE_IP:5555"
        echo "  Ou use a opção 1 do menu principal"
    else
        printf "%b\n" "   ${RED}✗ Não foi possível conectar via WiFi${NC}"
        echo
        printf "%b\n" "${YELLOW}Possíveis causas e soluções:${NC}"
        echo "  1. ${BLUE}Firewall/Router:${NC} Alguns roteadores bloqueiam a porta 5555"
        echo "     - Tente conectar a uma rede diferente"
        echo "     - Use hotspot do celular como teste"
        echo
        echo "  2. ${BLUE}ROM/Android:${NC} Algumas versões restringem ADB WiFi"
        echo "     - Verifique se há atualizações do sistema"
        echo "     - Procure por 'ADB over WiFi' nas configurações"
        echo
        echo "  3. ${BLUE}Rede corporativa:${NC} Isolamento de dispositivos"
        echo "     - Use uma rede doméstica"
        echo "     - Configure DMZ no roteador (avançado)"
        echo
        printf "%b\n" "${GREEN}Alternativa:${NC} Use via USB (sempre funciona)"
        echo "  scrcpy -s $DEVICE_ID"
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para gerenciar o submenu de conexão
connection_menu() {
    while true; do
        show_header
        show_connection_menu
        read choice

        case $choice in
            1)
                show_header
                printf "%b\n" "${GREEN}Conectando com configurações padrão (2M, 60fps)...${NC}"
                echo
                connect_device
                echo
                printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
                read
                ;;
            2)
                show_header
                printf "%b\n" "${GREEN}Conectando com qualidade baixa (1M, 30fps)...${NC}"
                echo
                connect_device "1M" "30"
                echo
                printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
                read
                ;;
            3)
                show_header
                printf "%b\n" "${GREEN}Conectando com qualidade alta (8M, 60fps)...${NC}"
                echo
                connect_device "8M" "60"
                echo
                printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
                read
                ;;
            4)
                show_header
                printf "%b\n" "${BLUE}Configuração personalizada de qualidade:${NC}"
                echo
                echo -n "Digite o bitrate (ex: 2M, 8M): "
                read custom_bitrate
                echo -n "Digite o FPS (ex: 30, 60): "
                read custom_fps
                echo -n "Opções extras do scrcpy (opcional): "
                read custom_extra

                show_header
                printf "%b\n" "${GREEN}Conectando com configurações personalizadas...${NC}"
                echo "Bitrate: $custom_bitrate, FPS: $custom_fps"
                [ ! -z "$custom_extra" ] && echo "Opções extras: $custom_extra"
                echo
                connect_device "$custom_bitrate" "$custom_fps" "$custom_extra"
                echo
                printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
                read
                ;;
            5)
                connect_usb
                ;;
            6)
                wifi_quick_fixes
                ;;
            0)
                return
                ;;
            *)
                printf "%b\n" "${RED}Opção inválida!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Função para gerenciar o submenu de diagnóstico
diagnostic_menu() {
    while true; do
        show_header
        show_diagnostic_menu
        read choice

        case $choice in
            1)
                run_diagnostics
                ;;
            2)
                run_troubleshooting
                ;;
            3)
                test_wifi_connectivity
                ;;
            4)
                show_error_logs
                ;;
            0)
                return
                ;;
            *)
                printf "%b\n" "${RED}Opção inválida!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Função para gerenciar o submenu de dispositivos
device_menu() {
    while true; do
        show_header
        show_device_menu
        read choice

        case $choice in
            1)
                list_devices
                ;;
            2)
                disconnect_wifi_devices
                ;;
            3)
                reconnect_wifi
                ;;
            4)
                reset_adb_connections
                ;;
            0)
                return
                ;;
            *)
                printf "%b\n" "${RED}Opção inválida!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Função para gerenciar o submenu de configurações
settings_menu() {
    while true; do
        show_header
        show_settings_menu
        read choice

        case $choice in
            1)
                if [ "$DEBUG" = true ]; then
                    DEBUG=false
                    printf "%b\n" "${GREEN}✓ Logs de debug desativados${NC}"
                else
                    DEBUG=true
                    printf "%b\n" "${GREEN}✓ Logs de debug ativados${NC}"
                fi
                sleep 2
                ;;
            2)
                configure_scrcpy_options
                ;;
            3)
                show_current_scrcpy_config
                ;;
            4)
                show_header
                printf "%b\n" "${BLUE}⚙️  Configurar Timeout de Conexão${NC}"
                echo
                printf "%b\n" "${CYAN}Timeout atual: $TIMEOUT segundos${NC}"
                echo -n "Digite o novo timeout (1-60 segundos): "
                read new_timeout

                if [[ $new_timeout =~ ^[0-9]+$ ]] && [ $new_timeout -ge 1 ] && [ $new_timeout -le 60 ]; then
                    TIMEOUT=$new_timeout
                    printf "%b\n" "${GREEN}✓ Timeout configurado para: $TIMEOUT segundos${NC}"
                else
                    printf "%b\n" "${RED}✗ Timeout inválido! Use um número entre 1 e 60${NC}"
                fi
                sleep 2
                ;;
            5)
                check_and_install_dependencies
                ;;
            6)
                show_header
                printf "%b\n" "${YELLOW}=== RESETAR CONFIGURAÇÕES SCRCPY ===${NC}"
                echo
                echo "Isso irá resetar TODAS as configurações do scrcpy para o padrão:"
                echo "• Todas as opções serão removidas"
                echo "• O scrcpy voltará ao comportamento padrão"
                echo "• Útil para resolver problemas de configuração"
                echo
                echo -n "Confirma o reset das configurações do scrcpy? [s/N]: "
                read confirm

                if [[ $confirm =~ ^[Ss]$ ]]; then
                    reset_scrcpy_configs
                    printf "%b\n" "${GREEN}✓ Configurações do scrcpy resetadas para o padrão${NC}"
                    printf "%b\n" "${YELLOW}Todas as opções personalizadas foram removidas${NC}"
                else
                    printf "%b\n" "${BLUE}Reset cancelado${NC}"
                fi
                sleep 3
                ;;
            7)
                show_header
                printf "%b\n" "${BLUE}ℹ️  Informações do Sistema${NC}"
                echo
                printf "%b\n" "${CYAN}=== VERSÕES ===${NC}"
                echo -n "scrcpy: "
                scrcpy --version 2>/dev/null | head -1 || echo "Não encontrado"
                echo -n "adb: "
                adb version 2>/dev/null | head -1 || echo "Não encontrado"
                echo -n "Sistema: "
                uname -s
                echo -n "Homebrew: "
                brew --version 2>/dev/null | head -1 || echo "Não encontrado"
                echo

                printf "%b\n" "${CYAN}=== CONFIGURAÇÕES ATUAIS DO SCRIPT ===${NC}"
                echo "Debug: $([ "$DEBUG" = true ] && echo "Ativado" || echo "Desativado")"
                echo "Timeout: $TIMEOUT segundos"
                echo "Bitrate padrão: ${DEFAULT_BITRATE:-2M}"
                echo "FPS padrão: ${DEFAULT_FPS:-60}"
                echo

                printf "%b\n" "${CYAN}=== CONFIGURAÇÕES SCRCPY ATIVAS ===${NC}"
                local active_options=$(build_scrcpy_options)
                if [ ! -z "$active_options" ]; then
                    echo "$active_options"
                else
                    echo "Nenhuma configuração personalizada"
                fi
                echo

                printf "%b\n" "${CYAN}=== DISPOSITIVOS CONECTADOS ===${NC}"
                adb devices | sed 1d | sed '/^$/d' | while read line; do
                    echo "• $line"
                done

                echo
                printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
                read
                ;;
            0)
                return
                ;;
            *)
                printf "%b\n" "${RED}Opção inválida!${NC}"
                sleep 2
                ;;
        esac
    done
}
# Função principal de conexão
connect_device() {
    local bitrate="2M"
    local fps="60"
    local custom_options=""

    # Aplicar configurações personalizadas se fornecidas
    if [ "$1" != "" ]; then
        bitrate="$1"
    fi
    if [ "$2" != "" ]; then
        fps="$2"
    fi
    if [ "$3" != "" ]; then
        custom_options="$3"
    fi

# Verifique se o scrcpy está instalado
if ! command -v scrcpy &> /dev/null
then
  printf "%b\n" "${RED}Erro: scrcpy não encontrado. Instale usando 'brew install scrcpy'.${NC}"
  return 1
fi

# Verifique se o adb está instalado
if ! command -v adb &> /dev/null
then
  printf "%b\n" "${RED}Erro: adb não encontrado. Instale o Android SDK Platform-Tools.${NC}"
  return 1
fi

# Verificar versão do scrcpy
SCRCPY_VERSION=$(check_scrcpy_version)
log "Usando scrcpy versão: $SCRCPY_VERSION"

# Reiniciar o servidor adb para garantir funcionamento correto
log "Reiniciando servidor adb..."
adb kill-server
sleep 2
adb start-server
sleep 2

# Verifique se há dispositivos conectados via WiFi
log "Verificando dispositivos WiFi conectados..."
WIFI_DEVICES=$(adb devices | grep '5555' | awk '{print $1}')

if [ ! -z "$WIFI_DEVICES" ]; then
  echo "Dispositivos conectados via WiFi encontrados:"
  echo "$WIFI_DEVICES"
  echo -n "Deseja desconectar todos os dispositivos WiFi? (y/N) "
  read DISCONNECT_CHOICE

  if [[ $DISCONNECT_CHOICE =~ ^[Yy]$ ]]; then
    log "Desconectando dispositivos WiFi..."
    for DEVICE in $WIFI_DEVICES; do
      log "Desconectando $DEVICE"
      adb disconnect $DEVICE
    done
    echo "Dispositivos WiFi desconectados."
    sleep 2
  else
    echo "Prosseguindo sem desconectar dispositivos WiFi."
  fi
fi

# Obtenha a lista de dispositivos conectados via USB
log "Verificando dispositivos USB conectados..."
DEVICES=$(adb devices | sed 1d | awk '$2=="device" {print $1}' | grep -v '^$' | grep -v '5555')

# Verificar se há dispositivos conectados
if [ -z "$DEVICES" ]; then
  printf "%b\n" "${RED}Erro: Nenhum dispositivo conectado via USB.${NC}"
  echo
  printf "%b\n" "${YELLOW}Soluções possíveis:${NC}"
  echo "  ${BLUE}1. Verificar conexão USB:${NC}"
  echo "     - Cabo USB funcionando corretamente"
  echo "     - Porta USB do Mac funcionando"
  echo "     - Tente trocar o cabo ou porta USB"
  echo
  echo "  ${BLUE}2. Configurações do Android:${NC}"
  echo "     - Ative 'Opções do desenvolvedor'"
  echo "     - Ative 'Depuração USB'"
  echo "     - Ative 'Depuração USB (Modo de segurança)'"
  echo "     - Escolha 'Transferir arquivos' no modo USB"
  echo
  echo "  ${BLUE}3. Autorização:${NC}"
  echo "     - Aceite o popup de autorização no celular"
  echo "     - Marque 'Sempre permitir deste computador'"
  echo
  printf "%b\n" "${BLUE}Estado atual dos dispositivos:${NC}"
  adb devices -l
  echo
  printf "%b\n" "${YELLOW}Tente executar: adb kill-server && adb start-server${NC}"
  return 1
fi

log "Dispositivos USB encontrados: $DEVICES"

# Conta o número de dispositivos
DEVICE_COUNT=$(echo "$DEVICES" | wc -l | xargs)

# Se houver apenas um dispositivo, use-o automaticamente
if [ "$DEVICE_COUNT" -eq 1 ]; then
  DEVICE_ID=$DEVICES
else
  # Se houver vários dispositivos, peça ao usuário para escolher um
  echo "Selecione o dispositivo para conectar:"
  select DEVICE_ID in $DEVICES; do
    if [ -n "$DEVICE_ID" ]; then
      break
    else
      echo "Seleção inválida."
    fi
  done
fi

# Obtenha o endereço IP do dispositivo
log "Obtendo endereço IP do dispositivo $DEVICE_ID..."

# Múltiplas tentativas para obter o IP
DEVICE_IP=""
for attempt in {1..3}; do
    log "Tentativa $attempt de obter IP..."

    # Método 1: ip route
    DEVICE_IP=$(adb -s $DEVICE_ID shell ip route 2>/dev/null | awk '/wlan0/ {print $9}' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n 1 | tr -d '\r\n')

    # Método 2: ifconfig wlan0 se o primeiro falhar
    if [ -z "$DEVICE_IP" ]; then
        DEVICE_IP=$(adb -s $DEVICE_ID shell ifconfig wlan0 2>/dev/null | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}' | tr -d '\r\n')
    fi

    # Método 3: ip addr show wlan0
    if [ -z "$DEVICE_IP" ]; then
        DEVICE_IP=$(adb -s $DEVICE_ID shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | tr -d '\r\n')
    fi

    if [ ! -z "$DEVICE_IP" ]; then
        log "IP encontrado: $DEVICE_IP"
        break
    fi

    log "IP não encontrado na tentativa $attempt, aguardando..."
    sleep 2
done

if [ -z "$DEVICE_IP" ]; then
    printf "%b\n" "${RED}Erro: Não foi possível obter o endereço IP do dispositivo.${NC}"
    echo "Certifique-se de que o dispositivo está conectado ao WiFi."
    return 1
fi

log "Endereço IP do dispositivo: $DEVICE_IP"

# Verifique se o dispositivo já está conectado via WiFi
log "Verificando se dispositivo já está conectado via WiFi..."
ALREADY_CONNECTED=$(adb devices | grep "$DEVICE_IP:5555" | awk '{print $1}')

if [ -z "$ALREADY_CONNECTED" ]; then
  # Conecte o adb via WiFi apenas se o dispositivo não estiver já conectado
  log "Configurando dispositivo para modo TCP/IP na porta 5555..."
  if ! adb -s $DEVICE_ID tcpip 5555; then
    printf "%b\n" "${RED}Erro: Falha ao configurar modo TCP/IP no dispositivo.${NC}"
    return 1
  fi

  log "Aguardando dispositivo reiniciar em modo TCP/IP..."
  sleep 3 # Aumentado o tempo de espera

  log "Tentando conectar via WiFi ao $DEVICE_IP:5555..."

  # Tentar múltiplas vezes com diferentes intervalos
  echo "Tentando conectar... (pode levar até 30 segundos)"
  CONNECTION_SUCCESS=false

  for connection_attempt in {1..6}; do
    echo "Tentativa $connection_attempt de 6..."

    if adb connect $DEVICE_IP:5555 2>/dev/null | grep -q "connected"; then
      CONNECTION_SUCCESS=true
      printf "%b\n" "${GREEN}Conexão adb via WiFi estabelecida com sucesso.${NC}"
      break
    else
      echo "Falhou, aguardando 5 segundos..."
      sleep 5

      # Re-executar tcpip nas tentativas 3 e 5
      if [ $connection_attempt -eq 3 ] || [ $connection_attempt -eq 5 ]; then
        echo "Re-configurando modo TCP/IP..."
        adb -s $DEVICE_ID tcpip 5555 >/dev/null 2>&1
        sleep 3
      fi
    fi
  done

  if [ "$CONNECTION_SUCCESS" = false ]; then
    printf "%b\n" "${RED}Erro: Falha ao conectar via WiFi após múltiplas tentativas.${NC}"
    echo
    printf "%b\n" "${YELLOW}Possíveis soluções:${NC}"
    echo "  1. ${BLUE}Problema comum:${NC} O dispositivo demora para ativar a porta TCP"
    echo "  2. ${BLUE}Firewall/Router:${NC} Bloqueio da porta 5555"
    echo "  3. ${BLUE}Rede corporativa:${NC} Isolamento de dispositivos"
    echo "  4. ${BLUE}Configuração do Android:${NC} Algumas ROMs bloqueiam ADB WiFi"
    echo
    printf "%b\n" "${CYAN}Teste manual:${NC}"
    echo "  1. Execute: adb -s $DEVICE_ID tcpip 5555"
    echo "  2. Aguarde 10 segundos"
    echo "  3. Execute: adb connect $DEVICE_IP:5555"
    echo "  4. Se falhar, tente reiniciar WiFi no celular"
    echo
    printf "%b\n" "${CYAN}Alternativa:${NC} Use o scrcpy via USB (funciona sem WiFi)"
    echo "  scrcpy -s $DEVICE_ID"
    return 1
  fi
else
  echo "Dispositivo já conectado via WiFi."
fi

# Verificar se o dispositivo está realmente pronto para scrcpy
log "Verificando se dispositivo está pronto para scrcpy..."
for check_attempt in {1..5}; do
    if adb -s $DEVICE_IP:5555 shell echo "test" &>/dev/null; then
        log "Dispositivo respondendo corretamente (tentativa $check_attempt)"
        break
    else
        log "Dispositivo não respondeu na tentativa $check_attempt, aguardando..."
        sleep 2
    fi

    if [ $check_attempt -eq 5 ]; then
        printf "%b\n" "${RED}Erro: Dispositivo não está respondendo via WiFi.${NC}"
        return 1
    fi
done

# Configurar opções do scrcpy baseado na versão e configurações salvas
log "Configurando opções do scrcpy..."
SCRCPY_OPTIONS=$(build_scrcpy_options)

# Para versões 3.x do scrcpy, algumas opções mudaram
if [[ $SCRCPY_VERSION == "3."* ]]; then
    log "Usando configurações para scrcpy 3.x"
    # Verificar se always-on-top não foi desabilitado nas configurações
    if [ -z "$SCRCPY_ALWAYS_ON_TOP" ] && ! echo "$SCRCPY_OPTIONS" | grep -q "always-on-top"; then
        SCRCPY_OPTIONS="$SCRCPY_OPTIONS --always-on-top"
    fi
else
    log "Usando configurações para scrcpy 2.x ou anterior"
    # Verificar se always-on-top não foi desabilitado nas configurações
    if [ -z "$SCRCPY_ALWAYS_ON_TOP" ] && ! echo "$SCRCPY_OPTIONS" | grep -q "always-on-top"; then
        SCRCPY_OPTIONS="$SCRCPY_OPTIONS --always-on-top"
    fi
fi

# Adicionar opções para melhor performance se não configuradas
if [ -z "$SCRCPY_MAX_FPS" ] && ! echo "$SCRCPY_OPTIONS" | grep -q "max-fps"; then
    SCRCPY_OPTIONS="$SCRCPY_OPTIONS --max-fps=$fps"
fi

if [ -z "$SCRCPY_VIDEO_BIT_RATE" ] && ! echo "$SCRCPY_OPTIONS" | grep -q "video-bit-rate"; then
    SCRCPY_OPTIONS="$SCRCPY_OPTIONS --video-bit-rate=$bitrate"
fi

# Adicionar opções customizadas se fornecidas
if [ ! -z "$custom_options" ]; then
    SCRCPY_OPTIONS="$SCRCPY_OPTIONS $custom_options"
fi

log "Opções do scrcpy: $SCRCPY_OPTIONS"

# Inicie o scrcpy com as opções especificadas
printf "%b\n" "${GREEN}Iniciando scrcpy com o dispositivo '$DEVICE_ID' via WiFi...${NC}"
log "Comando: scrcpy $SCRCPY_OPTIONS -s $DEVICE_IP:5555"

if scrcpy $SCRCPY_OPTIONS -s $DEVICE_IP:5555; then
  printf "%b\n" "${GREEN}Conectado ao dispositivo '$DEVICE_ID' via WiFi com scrcpy.${NC}"
else
  printf "%b\n" "${RED}Erro: Falha ao iniciar o scrcpy.${NC}"
  echo "Logs de debug:"
  echo "  - Dispositivo: $DEVICE_ID"
  echo "  - IP: $DEVICE_IP"
  echo "  - Versão scrcpy: $SCRCPY_VERSION"
  echo "  - Opções: $SCRCPY_OPTIONS"
  echo ""
  echo "Tente executar manualmente:"
  echo "  scrcpy --help"
  echo "  adb devices"
  echo "  scrcpy -s $DEVICE_IP:5555 --verbosity=debug"
  return 1
fi
}

# Função para obter IP do dispositivo com métodos alternativos
get_device_ip() {
    local device_id="$1"
    local device_ip=""

    log "Obtendo IP do dispositivo $device_id..."

    # Método 1: ip route
    device_ip=$(adb -s $device_id shell ip route 2>/dev/null | awk '/wlan0/ {print $9}' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n 1 | tr -d '\r\n')

    # Método 2: ifconfig wlan0 se o primeiro falhar
    if [ -z "$device_ip" ]; then
        device_ip=$(adb -s $device_id shell ifconfig wlan0 2>/dev/null | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}' | tr -d '\r\n')
    fi

    # Método 3: ip addr show wlan0
    if [ -z "$device_ip" ]; then
        device_ip=$(adb -s $device_id shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | tr -d '\r\n')
    fi

    # Método 4: getprop dhcp.wlan0.ipaddress (alternativo)
    if [ -z "$device_ip" ]; then
        device_ip=$(adb -s $device_id shell getprop dhcp.wlan0.ipaddress 2>/dev/null | tr -d '\r\n')
    fi

    echo "$device_ip"
}

# Função para testar conectividade WiFi
test_wifi_connectivity() {
    show_header
    printf "%b\n" "${YELLOW}=== TESTE DE CONECTIVIDADE WIFI ===${NC}"
    echo

    # Verificar dispositivos USB
    USB_DEVICES=$(adb devices | sed 1d | awk '$2=="device" {print $1}' | grep -v '^$' | grep -v '5555')
    if [ -z "$USB_DEVICES" ]; then
        printf "%b\n" "${RED}Nenhum dispositivo USB conectado para testar${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    DEVICE_ID=$(echo "$USB_DEVICES" | head -n 1)
    printf "%b\n" "${BLUE}Testando conectividade com dispositivo: $DEVICE_ID${NC}"
    echo

    # Teste 1: Obter IP
    echo "1. Obtendo IP do dispositivo..."
    DEVICE_IP=$(get_device_ip "$DEVICE_ID")

    if [ ! -z "$DEVICE_IP" ]; then
        printf "%b\n" "   ${GREEN}✓ IP encontrado: $DEVICE_IP${NC}"
    else
        printf "%b\n" "   ${RED}✗ Não foi possível obter IP${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    # Teste 2: Verificar mesma rede
    echo "2. Verificando se estão na mesma rede..."
    MAC_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}')
    MAC_NETWORK=$(echo $MAC_IP | cut -d. -f1-3)
    DEVICE_NETWORK=$(echo $DEVICE_IP | cut -d. -f1-3)

    if [ "$MAC_NETWORK" = "$DEVICE_NETWORK" ]; then
        printf "%b\n" "   ${GREEN}✓ Mac ($MAC_IP) e dispositivo ($DEVICE_IP) estão na mesma rede${NC}"
    else
        printf "%b\n" "   ${RED}✗ Mac e dispositivo estão em redes diferentes${NC}"
        printf "%b\n" "   ${YELLOW}SOLUÇÃO: Conecte ambos na mesma rede WiFi${NC}"
    fi

    # Teste 3: Ping
    echo "3. Testando ping..."
    if ping -c 3 -W 3000 $DEVICE_IP &>/dev/null; then
        printf "%b\n" "   ${GREEN}✓ Ping bem-sucedido${NC}"
    else
        printf "%b\n" "   ${RED}✗ Ping falhou${NC}"
        printf "%b\n" "   ${YELLOW}Possível problema de rede ou firewall${NC}"
    fi

    # Teste 4: Teste de porta TCP
    echo "4. Configurando modo TCP e testando conexão..."
    adb -s $DEVICE_ID tcpip 5555 >/dev/null 2>&1
    sleep 5

    if adb connect $DEVICE_IP:5555 2>/dev/null | grep -q "connected"; then
        printf "%b\n" "   ${GREEN}✓ Conexão TCP/IP bem-sucedida${NC}"
        echo
        printf "%b\n" "${GREEN}RESULTADO: Conectividade WiFi está funcionando!${NC}"

        # Desconectar para não interferir
        adb disconnect $DEVICE_IP:5555 >/dev/null 2>&1
    else
        printf "%b\n" "   ${RED}✗ Falha na conexão TCP/IP${NC}"
        echo
        printf "%b\n" "${RED}RESULTADO: Há problemas na conectividade WiFi${NC}"
        printf "%b\n" "${YELLOW}Use as soluções rápidas do menu de conexão${NC}"
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para construir opções do scrcpy baseadas nas configurações salvas
build_scrcpy_options() {
    local options=""

    # Controles
    [ ! -z "$SCRCPY_SHOW_TOUCHES" ] && options="$options --show-touches"
    [ ! -z "$SCRCPY_STAY_AWAKE" ] && options="$options --stay-awake"
    [ ! -z "$SCRCPY_NO_CONTROL" ] && options="$options --no-control"
    [ ! -z "$SCRCPY_TURN_SCREEN_OFF" ] && options="$options --turn-screen-off"

    # Vídeo
    [ ! -z "$SCRCPY_MAX_SIZE" ] && options="$options --max-size=$SCRCPY_MAX_SIZE"
    [ ! -z "$SCRCPY_MAX_FPS" ] && options="$options --max-fps=$SCRCPY_MAX_FPS"
    [ ! -z "$SCRCPY_VIDEO_BIT_RATE" ] && options="$options --video-bit-rate=$SCRCPY_VIDEO_BIT_RATE"
    [ ! -z "$SCRCPY_VIDEO_CODEC" ] && options="$options --video-codec=$SCRCPY_VIDEO_CODEC"
    [ ! -z "$SCRCPY_CROP" ] && options="$options --crop=$SCRCPY_CROP"
    [ ! -z "$SCRCPY_DISPLAY_ORIENTATION" ] && options="$options --display-orientation=$SCRCPY_DISPLAY_ORIENTATION"
    [ ! -z "$SCRCPY_RECORD_ORIENTATION" ] && options="$options --record-orientation=$SCRCPY_RECORD_ORIENTATION"
    [ ! -z "$SCRCPY_NO_VIDEO" ] && options="$options --no-video"

    # Áudio
    [ ! -z "$SCRCPY_AUDIO_BIT_RATE" ] && options="$options --audio-bit-rate=$SCRCPY_AUDIO_BIT_RATE"
    [ ! -z "$SCRCPY_AUDIO_CODEC" ] && options="$options --audio-codec=$SCRCPY_AUDIO_CODEC"
    [ ! -z "$SCRCPY_AUDIO_SOURCE" ] && options="$options --audio-source=$SCRCPY_AUDIO_SOURCE"
    [ ! -z "$SCRCPY_NO_AUDIO" ] && options="$options --no-audio"

    # Janela
    [ ! -z "$SCRCPY_WINDOW_TITLE" ] && options="$options --window-title='$SCRCPY_WINDOW_TITLE'"
    [ ! -z "$SCRCPY_ALWAYS_ON_TOP" ] && options="$options --always-on-top"
    [ ! -z "$SCRCPY_FULLSCREEN" ] && options="$options --fullscreen"
    [ ! -z "$SCRCPY_WINDOW_BORDERLESS" ] && options="$options --window-borderless"

    # Avançado
    [ ! -z "$SCRCPY_POWER_OFF_ON_CLOSE" ] && options="$options --power-off-on-close"
    [ ! -z "$SCRCPY_PRINT_FPS" ] && options="$options --print-fps"
    [ ! -z "$SCRCPY_NO_CLIPBOARD_AUTOSYNC" ] && options="$options --no-clipboard-autosync"
    [ ! -z "$SCRCPY_DISABLE_SCREENSAVER" ] && options="$options --disable-screensaver"
    [ ! -z "$SCRCPY_VERBOSITY" ] && options="$options --verbosity=$SCRCPY_VERBOSITY"

    # Opções customizadas
    [ ! -z "$SCRCPY_CUSTOM_OPTIONS" ] && options="$options $SCRCPY_CUSTOM_OPTIONS"

    echo "$options"
}

# Função para salvar configuração individual
save_config() {
    local var_name="$1"
    local var_value="$2"

    # Usar sed para atualizar a configuração no próprio script
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^${var_name}=.*/${var_name}=\"${var_value}\"/" "$0"
    else
        # Linux
        sed -i "s/^${var_name}=.*/${var_name}=\"${var_value}\"/" "$0"
    fi

    # Atualizar também na sessão atual
    eval "${var_name}=\"${var_value}\""
}

# Função para mostrar configuração atual do scrcpy
show_current_scrcpy_config() {
    show_header
    printf "%b\n" "${YELLOW}=== CONFIGURAÇÕES ATUAIS DO SCRCPY ===${NC}"
    echo

    local has_config=false

    printf "%b\n" "${BLUE}🎮 CONTROLES:${NC}"
    [ ! -z "$SCRCPY_SHOW_TOUCHES" ] && echo "  ✓ show-touches: Ativado" && has_config=true
    [ ! -z "$SCRCPY_STAY_AWAKE" ] && echo "  ✓ stay-awake: Ativado" && has_config=true
    [ ! -z "$SCRCPY_NO_CONTROL" ] && echo "  ✓ no-control: Ativado" && has_config=true
    [ ! -z "$SCRCPY_TURN_SCREEN_OFF" ] && echo "  ✓ turn-screen-off: Ativado" && has_config=true
    echo

    printf "%b\n" "${BLUE}🎥 VÍDEO:${NC}"
    [ ! -z "$SCRCPY_MAX_SIZE" ] && echo "  ✓ max-size: $SCRCPY_MAX_SIZE" && has_config=true
    [ ! -z "$SCRCPY_MAX_FPS" ] && echo "  ✓ max-fps: $SCRCPY_MAX_FPS" && has_config=true
    [ ! -z "$SCRCPY_VIDEO_BIT_RATE" ] && echo "  ✓ video-bit-rate: $SCRCPY_VIDEO_BIT_RATE" && has_config=true
    [ ! -z "$SCRCPY_VIDEO_CODEC" ] && echo "  ✓ video-codec: $SCRCPY_VIDEO_CODEC" && has_config=true
    [ ! -z "$SCRCPY_CROP" ] && echo "  ✓ crop: $SCRCPY_CROP" && has_config=true
    [ ! -z "$SCRCPY_NO_VIDEO" ] && echo "  ✓ no-video: Ativado" && has_config=true
    echo

    printf "%b\n" "${BLUE}🔊 ÁUDIO:${NC}"
    [ ! -z "$SCRCPY_AUDIO_BIT_RATE" ] && echo "  ✓ audio-bit-rate: $SCRCPY_AUDIO_BIT_RATE" && has_config=true
    [ ! -z "$SCRCPY_AUDIO_CODEC" ] && echo "  ✓ audio-codec: $SCRCPY_AUDIO_CODEC" && has_config=true
    [ ! -z "$SCRCPY_AUDIO_SOURCE" ] && echo "  ✓ audio-source: $SCRCPY_AUDIO_SOURCE" && has_config=true
    [ ! -z "$SCRCPY_NO_AUDIO" ] && echo "  ✓ no-audio: Ativado" && has_config=true
    echo

    printf "%b\n" "${BLUE}🪟 JANELA:${NC}"
    [ ! -z "$SCRCPY_WINDOW_TITLE" ] && echo "  ✓ window-title: $SCRCPY_WINDOW_TITLE" && has_config=true
    [ ! -z "$SCRCPY_ALWAYS_ON_TOP" ] && echo "  ✓ always-on-top: Ativado" && has_config=true
    [ ! -z "$SCRCPY_FULLSCREEN" ] && echo "  ✓ fullscreen: Ativado" && has_config=true
    [ ! -z "$SCRCPY_WINDOW_BORDERLESS" ] && echo "  ✓ window-borderless: Ativado" && has_config=true
    echo

    printf "%b\n" "${BLUE}🔧 AVANÇADO:${NC}"
    [ ! -z "$SCRCPY_POWER_OFF_ON_CLOSE" ] && echo "  ✓ power-off-on-close: Ativado" && has_config=true
    [ ! -z "$SCRCPY_PRINT_FPS" ] && echo "  ✓ print-fps: Ativado" && has_config=true
    [ ! -z "$SCRCPY_NO_CLIPBOARD_AUTOSYNC" ] && echo "  ✓ no-clipboard-autosync: Ativado" && has_config=true
    [ ! -z "$SCRCPY_DISABLE_SCREENSAVER" ] && echo "  ✓ disable-screensaver: Ativado" && has_config=true
    [ ! -z "$SCRCPY_VERBOSITY" ] && echo "  ✓ verbosity: $SCRCPY_VERBOSITY" && has_config=true
    echo

    printf "%b\n" "${BLUE}🎛️  PERSONALIZADO:${NC}"
    [ ! -z "$SCRCPY_CUSTOM_OPTIONS" ] && echo "  ✓ opções customizadas: $SCRCPY_CUSTOM_OPTIONS" && has_config=true
    echo

    if [ "$has_config" = false ]; then
        printf "%b\n" "${YELLOW}Nenhuma configuração personalizada definida.${NC}"
        printf "%b\n" "${CYAN}O scrcpy usará as configurações padrão.${NC}"
    else
        printf "%b\n" "${GREEN}Comando scrcpy completo que será executado:${NC}"
        printf "%b\n" "${CYAN}scrcpy $(build_scrcpy_options) -s DEVICE${NC}"
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para resetar configurações do scrcpy
reset_scrcpy_configs() {
    # Lista de todas as variáveis de configuração
    local config_vars=(
        "SCRCPY_ALWAYS_ON_TOP"
        "SCRCPY_FULLSCREEN"
        "SCRCPY_SHOW_TOUCHES"
        "SCRCPY_STAY_AWAKE"
        "SCRCPY_TURN_SCREEN_OFF"
        "SCRCPY_NO_CONTROL"
        "SCRCPY_MAX_SIZE"
        "SCRCPY_MAX_FPS"
        "SCRCPY_VIDEO_BIT_RATE"
        "SCRCPY_AUDIO_BIT_RATE"
        "SCRCPY_VIDEO_CODEC"
        "SCRCPY_AUDIO_CODEC"
        "SCRCPY_AUDIO_SOURCE"
        "SCRCPY_DISPLAY_ORIENTATION"
        "SCRCPY_RECORD_ORIENTATION"
        "SCRCPY_WINDOW_TITLE"
        "SCRCPY_DISABLE_SCREENSAVER"
        "SCRCPY_NO_AUDIO"
        "SCRCPY_NO_VIDEO"
        "SCRCPY_NO_CLIPBOARD_AUTOSYNC"
        "SCRCPY_PRINT_FPS"
        "SCRCPY_POWER_OFF_ON_CLOSE"
        "SCRCPY_WINDOW_BORDERLESS"
        "SCRCPY_CROP"
        "SCRCPY_VERBOSITY"
        "SCRCPY_CUSTOM_OPTIONS"
    )

    # Resetar cada configuração
    for var in "${config_vars[@]}"; do
        save_config "$var" ""
    done
}

# Função para configurar opções do scrcpy
configure_scrcpy_options() {
    while true; do
        show_header
        printf "%b\n" "${YELLOW}=== CONFIGURAR OPÇÕES DO SCRCPY ===${NC}"
        echo
        printf "%b\n" "${BLUE}Selecione uma categoria:${NC}"
        echo
        printf "%b\n" "${GREEN}1.${NC} 🎮 Controles"
        printf "%b\n" "${GREEN}2.${NC} 🎥 Vídeo"
        printf "%b\n" "${GREEN}3.${NC} 🔊 Áudio"
        printf "%b\n" "${GREEN}4.${NC} 🪟 Janela"
        printf "%b\n" "${GREEN}5.${NC} 🔧 Avançado"
        printf "%b\n" "${GREEN}6.${NC} 🎛️  Opções Personalizadas"
        printf "%b\n" "${YELLOW}7.${NC} 💾 Salvar todas as configurações"
        printf "%b\n" "${RED}8.${NC} 🗑️  Resetar todas as configurações"
        printf "%b\n" "${BLUE}0.${NC} ← Voltar"
        echo
        echo -n "Digite sua escolha [0-8]: "
        read choice

        case $choice in
            1) configure_controls ;;
            2) configure_video ;;
            3) configure_audio ;;
            4) configure_window ;;
            5) configure_advanced ;;
            6) configure_custom ;;
            7) save_all_configs ;;
            8)
                echo
                echo -n "Confirma o reset de TODAS as configurações? [s/N]: "
                read confirm
                if [[ $confirm =~ ^[Ss]$ ]]; then
                    reset_scrcpy_configs
                    printf "%b\n" "${GREEN}✓ Todas as configurações foram resetadas${NC}"
                    sleep 2
                fi
                ;;
            0) return ;;
            *) printf "%b\n" "${RED}Opção inválida!${NC}"; sleep 1 ;;
        esac
    done
}

# Função para verificar e instalar dependências
check_and_install_dependencies() {
    show_header
    printf "%b\n" "${YELLOW}=== VERIFICAR/INSTALAR DEPENDÊNCIAS ===${NC}"
    echo

    local need_install=false

    # Verificar Homebrew
    printf "%b\n" "${BLUE}1. Verificando Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        printf "%b\n" "   ${GREEN}✓ Homebrew está instalado${NC}"
        echo "   Versão: $(brew --version | head -1)"
    else
        printf "%b\n" "   ${RED}✗ Homebrew não encontrado${NC}"
        need_install=true
    fi
    echo

    # Verificar scrcpy
    printf "%b\n" "${BLUE}2. Verificando scrcpy...${NC}"
    if command -v scrcpy &> /dev/null; then
        printf "%b\n" "   ${GREEN}✓ scrcpy está instalado${NC}"
        echo "   Versão: $(scrcpy --version | head -1)"
    else
        printf "%b\n" "   ${RED}✗ scrcpy não encontrado${NC}"
        need_install=true
    fi
    echo

    # Verificar adb
    printf "%b\n" "${BLUE}3. Verificando adb...${NC}"
    if command -v adb &> /dev/null; then
        printf "%b\n" "   ${GREEN}✓ adb está instalado${NC}"
        echo "   Versão: $(adb --version | head -1)"
    else
        printf "%b\n" "   ${RED}✗ adb não encontrado${NC}"
        need_install=true
    fi
    echo

    if [ "$need_install" = true ]; then
        printf "%b\n" "${YELLOW}Algumas dependências precisam ser instaladas.${NC}"
        echo -n "Deseja instalar automaticamente? [s/N]: "
        read install_choice

        if [[ $install_choice =~ ^[Ss]$ ]]; then
            echo
            printf "%b\n" "${BLUE}Iniciando instalação...${NC}"

            # Instalar Homebrew se necessário
            if ! command -v brew &> /dev/null; then
                echo "Instalando Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                # Adicionar ao PATH
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi

            # Instalar scrcpy
            if ! command -v scrcpy &> /dev/null; then
                echo "Instalando scrcpy..."
                brew install scrcpy
            fi

            # Instalar adb (Android Platform Tools)
            if ! command -v adb &> /dev/null; then
                echo "Instalando Android Platform Tools (adb)..."
                brew install --cask android-platform-tools
            fi

            echo
            printf "%b\n" "${GREEN}✓ Instalação concluída!${NC}"
            printf "%b\n" "${CYAN}Reinicie o terminal e execute o script novamente.${NC}"
        fi
    else
        printf "%b\n" "${GREEN}✓ Todas as dependências estão instaladas e funcionando!${NC}"
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Funções auxiliares para configuração das categorias
configure_controls() {
    show_header
    printf "%b\n" "${YELLOW}=== CONFIGURAR CONTROLES ===${NC}"
    echo
    echo "1. show-touches (Mostrar toques): $([ ! -z "$SCRCPY_SHOW_TOUCHES" ] && echo "Ativado" || echo "Desativado")"
    echo "2. stay-awake (Manter acordado): $([ ! -z "$SCRCPY_STAY_AWAKE" ] && echo "Ativado" || echo "Desativado")"
    echo "3. no-control (Apenas visualização): $([ ! -z "$SCRCPY_NO_CONTROL" ] && echo "Ativado" || echo "Desativado")"
    echo "4. turn-screen-off (Desligar tela): $([ ! -z "$SCRCPY_TURN_SCREEN_OFF" ] && echo "Ativado" || echo "Desativado")"
    echo "0. Voltar"
    echo
    echo -n "Digite sua escolha [0-4]: "
    read choice

    case $choice in
        1) toggle_config "SCRCPY_SHOW_TOUCHES" "true" ;;
        2) toggle_config "SCRCPY_STAY_AWAKE" "true" ;;
        3) toggle_config "SCRCPY_NO_CONTROL" "true" ;;
        4) toggle_config "SCRCPY_TURN_SCREEN_OFF" "true" ;;
        0) return ;;
    esac
}

configure_video() {
    show_header
    printf "%b\n" "${YELLOW}=== CONFIGURAR VÍDEO ===${NC}"
    echo
    echo "1. max-size (Resolução): ${SCRCPY_MAX_SIZE:-"Padrão"}"
    echo "2. max-fps (FPS): ${SCRCPY_MAX_FPS:-"Padrão"}"
    echo "3. video-bit-rate (Bitrate): ${SCRCPY_VIDEO_BIT_RATE:-"Padrão"}"
    echo "4. video-codec (Codec): ${SCRCPY_VIDEO_CODEC:-"Padrão"}"
    echo "5. no-video (Desabilitar vídeo): $([ ! -z "$SCRCPY_NO_VIDEO" ] && echo "Ativado" || echo "Desativado")"
    echo "0. Voltar"
    echo
    echo -n "Digite sua escolha [0-5]: "
    read choice

    case $choice in
        1)
            echo -n "Digite a resolução máxima (ex: 1080, 1920): "
            read value
            save_config "SCRCPY_MAX_SIZE" "$value"
            ;;
        2)
            echo -n "Digite o FPS máximo (ex: 30, 60): "
            read value
            save_config "SCRCPY_MAX_FPS" "$value"
            ;;
        3)
            echo -n "Digite o bitrate (ex:  2M, 8M): "
            read value
            save_config "SCRCPY_VIDEO_BIT_RATE" "$value"
            ;;
        4)
            echo "Codecs disponíveis: h264, h265, av1"
            echo -n "Digite o codec: "
            read value
            save_config "SCRCPY_VIDEO_CODEC" "$value"
            ;;
        5) toggle_config "SCRCPY_NO_VIDEO" "true" ;;
        0) return ;;
    esac
}

configure_audio() {
    show_header
    printf "%b\n" "${YELLOW}=== CONFIGURAR ÁUDIO ===${NC}"
    echo
    echo "1. audio-bit-rate (Bitrate): ${SCRCPY_AUDIO_BIT_RATE:-"Padrão"}"
    echo "2. audio-codec (Codec): ${SCRCPY_AUDIO_CODEC:-"Padrão"}"
    echo "3. audio-source (Fonte): ${SCRCPY_AUDIO_SOURCE:-"Padrão"}"
    echo "4. no-audio (Desabilitar áudio): $([ ! -z "$SCRCPY_NO_AUDIO" ] && echo "Ativado" || echo "Desativado")"
    echo "0. Voltar"
    echo
    echo -n "Digite sua escolha [0-4]: "
    read choice

    case $choice in
        1)
            echo -n "Digite o bitrate de áudio (ex: 128k): "
            read value
            save_config "SCRCPY_AUDIO_BIT_RATE" "$value"
            ;;
        2)
            echo "Codecs disponíveis: opus, aac, flac, raw"
            echo -n "Digite o codec: "
            read value
            save_config "SCRCPY_AUDIO_CODEC" "$value"
            ;;
        3)
            echo -n "Digite a fonte de áudio (ex: output, mic): "
            read value
            save_config "SCRCPY_AUDIO_SOURCE" "$value"
            ;;
        4) toggle_config "SCRCPY_NO_AUDIO" "true" ;;
        0) return ;;
    esac
}

configure_window() {
    show_header
    printf "%b\n" "${YELLOW}=== CONFIGURAR JANELA ===${NC}"
    echo
    echo "1. window-title (Título): ${SCRCPY_WINDOW_TITLE:-"Padrão"}"
    echo "2. always-on-top (Sempre no topo): $([ ! -z "$SCRCPY_ALWAYS_ON_TOP" ] && echo "Ativado" || echo "Desativado")"
    echo "3. fullscreen (Tela cheia): $([ ! -z "$SCRCPY_FULLSCREEN" ] && echo "Ativado" || echo "Desativado")"
    echo "4. window-borderless (Sem bordas): $([ ! -z "$SCRCPY_WINDOW_BORDERLESS" ] && echo "Ativado" || echo "Desativado")"
    echo "0. Voltar"
    echo
    echo -n "Digite sua escolha [0-4]: "
    read choice

    case $choice in
        1)
            echo -n "Digite o título da janela: "
            read value
            save_config "SCRCPY_WINDOW_TITLE" "$value"
            ;;
        2) toggle_config "SCRCPY_ALWAYS_ON_TOP" "true" ;;
        3) toggle_config "SCRCPY_FULLSCREEN" "true" ;;
        4) toggle_config "SCRCPY_WINDOW_BORDERLESS" "true" ;;
        0) return ;;
    esac
}

configure_advanced() {
    show_header
    printf "%b\n" "${YELLOW}=== CONFIGURAÇÕES AVANÇADAS ===${NC}"
    echo
    echo "1. power-off-on-close (Desligar ao fechar): $([ ! -z "$SCRCPY_POWER_OFF_ON_CLOSE" ] && echo "Ativado" || echo "Desativado")"
    echo "2. print-fps (Mostrar FPS): $([ ! -z "$SCRCPY_PRINT_FPS" ] && echo "Ativado" || echo "Desativado")"
    echo "3. no-clipboard-autosync (Sem sincronização): $([ ! -z "$SCRCPY_NO_CLIPBOARD_AUTOSYNC" ] && echo "Ativado" || echo "Desativado")"
    echo "4. disable-screensaver (Sem proteção de tela): $([ ! -z "$SCRCPY_DISABLE_SCREENSAVER" ] && echo "Ativado" || echo "Desativado")"
    echo "5. verbosity (Nível de log): ${SCRCPY_VERBOSITY:-"Padrão"}"
    echo "0. Voltar"
    echo
    echo -n "Digite sua escolha [0-5]: "
    read choice

    case $choice in
        1) toggle_config "SCRCPY_POWER_OFF_ON_CLOSE" "true" ;;
        2) toggle_config "SCRCPY_PRINT_FPS" "true" ;;
        3) toggle_config "SCRCPY_NO_CLIPBOARD_AUTOSYNC" "true" ;;
        4) toggle_config "SCRCPY_DISABLE_SCREENSAVER" "true" ;;
        5)
            echo "Níveis disponíveis: verbose, debug, info, warn, error"
            echo -n "Digite o nível: "
            read value
            save_config "SCRCPY_VERBOSITY" "$value"
            ;;
        0) return ;;
    esac
}

configure_custom() {
    show_header
    printf "%b\n" "${YELLOW}=== OPÇÕES PERSONALIZADAS ===${NC}"
    echo
    echo "Opções atuais: ${SCRCPY_CUSTOM_OPTIONS:-"Nenhuma"}"
    echo
    echo "Digite opções adicionais do scrcpy (separadas por espaço):"
    echo "Exemplo: --disable-screensaver --print-fps"
    echo
    echo -n "Opções: "
    read value
    save_config "SCRCPY_CUSTOM_OPTIONS" "$value"
    printf "%b\n" "${GREEN}✓ Opções personalizadas salvas${NC}"
    sleep 2
}

# Função auxiliar para alternar configurações
toggle_config() {
    local var_name="$1"
    local var_value="$2"

    # Verificar se a variável está definida
    local current_value
    eval "current_value=\"\$$var_name\""

    if [ -z "$current_value" ]; then
        save_config "$var_name" "$var_value"
        printf "%b\n" "${GREEN}✓ $var_name ativado${NC}"
    else
        save_config "$var_name" ""
        printf "%b\n" "${YELLOW}✓ $var_name desativado${NC}"
    fi

    sleep 1
}

# Função para salvar todas as configurações
save_all_configs() {
    show_header
    printf "%b\n" "${YELLOW}=== SALVAR TODAS AS CONFIGURAÇÕES ===${NC}"
    echo
    echo "Salvando configurações atuais no script..."

    # As configurações já são salvas automaticamente quando modificadas
    # Esta função serve principalmente para mostrar feedback

    printf "%b\n" "${GREEN}✓ Todas as configurações foram salvas permanentemente${NC}"
    printf "%b\n" "${CYAN}As configurações serão mantidas entre execuções do script${NC}"
    echo
    echo "Configurações ativas:"
    build_scrcpy_options | tr ' ' '\n' | grep -v '^$' | sed 's/^/  /'
    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para desconectar dispositivos WiFi
disconnect_wifi_devices() {
    show_header
    printf "%b\n" "${YELLOW}=== DESCONECTAR DISPOSITIVOS WIFI ===${NC}"
    echo

    # Obter lista de dispositivos WiFi conectados
    WIFI_DEVICES=$(adb devices | grep '5555' | awk '{print $1}')

    if [ -z "$WIFI_DEVICES" ]; then
        printf "%b\n" "${YELLOW}Nenhum dispositivo WiFi conectado encontrado${NC}"
        echo
        printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
        read
        return
    fi

    printf "%b\n" "${BLUE}Dispositivos WiFi conectados:${NC}"
    echo "$WIFI_DEVICES"
    echo

    echo -n "Deseja desconectar todos os dispositivos WiFi? [s/N]: "
    read confirm

    if [[ $confirm =~ ^[Ss]$ ]]; then
        echo
        printf "%b\n" "${BLUE}Desconectando dispositivos WiFi...${NC}"
        for DEVICE in $WIFI_DEVICES; do
            echo "Desconectando $DEVICE..."
            adb disconnect $DEVICE
        done
        echo
        printf "%b\n" "${GREEN}✓ Todos os dispositivos WiFi foram desconectados${NC}"
    else
        printf "%b\n" "${BLUE}Operação cancelada${NC}"
    fi

    echo
    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Função para troubleshooting avançado
run_troubleshooting() {
    show_header
    printf "%b\n" "${YELLOW}=== TROUBLESHOOTING AVANÇADO ===${NC}"
    echo

    printf "%b\n" "${BLUE}Executando diagnóstico avançado...${NC}"
    echo

    # 1. Verificar processos ADB
    printf "%b\n" "${CYAN}1. Verificando processos ADB:${NC}"
    if pgrep -f adb > /dev/null; then
        printf "%b\n" "   ${GREEN}✓ Processos ADB encontrados${NC}"
        ps aux | grep adb | grep -v grep | head -3
    else
        printf "%b\n" "   ${YELLOW}! Nenhum processo ADB ativo${NC}"
    fi
    echo

    # 2. Verificar portas ocupadas
    printf "%b\n" "${CYAN}2. Verificando portas relacionadas:${NC}"
    PORTS=(5037 5555 5556 5557 5558 5559)
    for port in "${PORTS[@]}"; do
        if lsof -i :$port 2>/dev/null | grep -q LISTEN; then
            printf "%b\n" "   ${GREEN}✓ Porta $port em uso${NC}"
        else
            printf "%b\n" "   ${YELLOW}! Porta $port livre${NC}"
        fi
    done
    echo

    # 3. Testar conectividade com Google DNS
    printf "%b\n" "${CYAN}3. Testando conectividade de rede:${NC}"
    if ping -c 1 8.8.8.8 &>/dev/null; then
        printf "%b\n" "   ${GREEN}✓ Conectividade com internet OK${NC}"
    else
        printf "%b\n" "   ${RED}✗ Problemas de conectividade${NC}"
    fi
    echo

    # 4. Verificar versões e compatibilidade
    printf "%b\n" "${CYAN}4. Verificando compatibilidade:${NC}"
    SCRCPY_VERSION=$(scrcpy --version 2>/dev/null | head -1)
    ADB_VERSION=$(adb --version 2>/dev/null | head -1)

    if [[ $SCRCPY_VERSION == *"3."* ]]; then
        printf "%b\n" "   ${GREEN}✓ scrcpy 3.x detectado${NC}"
    elif [[ $SCRCPY_VERSION == *"2."* ]]; then
        printf "%b\n" "   ${YELLOW}! scrcpy 2.x detectado (considere atualizar)${NC}"
    else
        printf "%b\n" "   ${RED}✗ Versão do scrcpy não reconhecida${NC}"
    fi
    echo

    # 5. Limpeza automática
    printf "%b\n" "${CYAN}5. Executando limpeza automática:${NC}"
    echo "   Parando servidor ADB..."
    adb kill-server 2>/dev/null
    sleep 2
    echo "   Iniciando servidor ADB..."
    adb start-server 2>/dev/null
    sleep 2
    echo "   Limpando cache de conexões..."
    adb disconnect 2>/dev/null
    printf "%b\n" "   ${GREEN}✓ Limpeza concluída${NC}"
    echo

    # 6. Sugestões personalizadas
    printf "%b\n" "${CYAN}6. Sugestões de troubleshooting:${NC}"
    echo "   • Reinicie o WiFi no dispositivo Android"
    echo "   • Verifique se ambos estão na mesma rede"
    echo "   • Desative temporariamente firewall/antivírus"
    echo "   • Tente usar hotspot do celular como teste"
    echo "   • Verifique se a porta 5555 não está bloqueada"
    echo

    printf "%b\n" "${YELLOW}Pressione Enter para voltar...${NC}"
    read
}

# Loop principal do menu
main_menu() {
    while true; do
        show_header
        show_main_menu
        read choice

        case $choice in
            1)
                # Submenu de Conexão
                connection_menu
                ;;
            2)
                # Submenu de Diagnóstico
                diagnostic_menu
                ;;
            3)
                # Submenu de Dispositivos
                device_menu
                ;;
            4)
                # Submenu de Configurações
                settings_menu
                ;;
            0)
                show_header
                printf "%b\n" "${GREEN}Obrigado por usar o SCRCPY Manager!${NC}"
                printf "%b\n" "${CYAN}Até logo! 👋${NC}"
                exit 0
                ;;
            *)
                printf "%b\n" "${RED}Opção inválida! Pressione Enter para tentar novamente...${NC}"
                read
                ;;
        esac
    done
}

# Verificar dependências na inicialização
check_dependencies() {
    local missing_deps=false

    if ! command -v scrcpy &> /dev/null; then
        printf "%b\n" "${RED}✗ scrcpy não encontrado${NC}"
        echo "  Use o menu Configurações > Verificar/Instalar dependências"
        missing_deps=true
    fi

    if ! command -v adb &> /dev/null; then
        printf "%b\n" "${RED}✗ adb não encontrado${NC}"
        echo "  Use o menu Configurações > Verificar/Instalar dependências"
        missing_deps=true
    fi

    if [ "$missing_deps" = true ]; then
        echo
        printf "%b\n" "${YELLOW}Algumas dependências estão faltando.${NC}"
        printf "%b\n" "${CYAN}Você pode instalá-las automaticamente pelo menu de configurações.${NC}"
        echo
        echo -n "Pressione Enter para continuar ou Ctrl+C para sair..."
        read
    fi
}

# Iniciar o programa
show_header
printf "%b\n" "${BLUE}Verificando dependências...${NC}"
check_dependencies
printf "%b\n" "${GREEN}✓ Todas as dependências estão instaladas${NC}"
sleep 1

# Iniciar menu principal
main_menu

# Garante que a mensagem seja exibida antes do encerramento do script
trap 'echo -e "\033[1;31mPara encerrar o compartilhamento de tela, pressione Ctrl + C no terminal.\033[0m"' EXIT


