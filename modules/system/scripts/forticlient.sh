#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_forticlient() {
    log "Instalando FortiClient VPN..."

    # Verifica se já está instalado
    if command -v forticlient &> /dev/null; then
        log "FortiClient VPN já está instalado"
        return 0
    fi

    # Configura para o usuário atual (não root)
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    local TEMP_DIR="/tmp/forticlient"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Instala dependências necessárias
    log "Baixando dependências necessárias..."
    wget "http://mirrors.kernel.org/ubuntu/pool/universe/liba/libappindicator/libappindicator1_12.10.1+20.10.20200706.1-0ubuntu1_amd64.deb"
    wget "http://mirrors.kernel.org/ubuntu/pool/universe/libd/libdbusmenu/libdbusmenu-gtk4_16.04.1+18.10.20180917-0ubuntu8_amd64.deb"

    log "Instalando dependências..."
    if ! apt install -y ./libappindicator1_12.10.1+20.10.20200706.1-0ubuntu1_amd64.deb ./libdbusmenu-gtk4_16.04.1+18.10.20180917-0ubuntu8_amd64.deb; then
        error "Falha ao instalar dependências"
        return 1
    fi
    
    # Verifica se já existe um arquivo .deb na pasta temp
    if ! ls forticlient*.deb &> /dev/null; then
        # Baixa o FortiClient VPN apenas se não existir
        log "Baixando FortiClient VPN..."
        wget -O forticlient.deb "https://filestore.fortinet.com/forticlient/forticlient_vpn_7.4.0.1636_amd64.deb"

        if [ $? -ne 0 ]; then
            error "Falha ao baixar o FortiClient VPN"
            rm -rf "$TEMP_DIR"
            return 1
        fi
    else
        log "Usando arquivo .deb existente..."
    fi

    # Instala o pacote
    log "Instalando FortiClient VPN..."
    if ! dpkg -i forticlient*.deb; then
        log "Resolvendo dependências..."
        apt-get install -f -y
        if ! dpkg -i forticlient*.deb; then
            error "Falha ao instalar o FortiClient VPN"
            return 1
        fi
    fi

    # Verifica se a instalação foi bem sucedida
    if command -v forticlient &> /dev/null; then
        log "FortiClient VPN instalado com sucesso!"
        log "Para usar o VPN, execute: forticlient"
        # Limpa arquivos temporários somente após sucesso
        cd -
        rm -rf "$TEMP_DIR"
        return 0
    else
        error "Falha ao instalar o FortiClient VPN"
        return 1
    fi
}

# Executa a instalação
install_forticlient 