#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_insync() {
    log "Instalando Insync..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Verifica se já está instalado e se não está em modo forçado
    if command -v insync &> /dev/null && [ "$1" != "--force" ]; then
        log "Insync já está instalado"
        log "Use --force para reinstalar"
        return 0
    fi

    # Se estiver em modo forçado, remove a instalação anterior
    if [ "$1" == "--force" ]; then
        log "Modo forçado: removendo instalação anterior..."
        apt-get remove -y insync
        apt-get autoremove -y
        apt-get clean
        rm -rf ~/.config/Insync
    fi

    # Cria diretório temporário
    local TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # URL do pacote Insync
    local INSYNC_URL="https://cdn.insynchq.com/builds/linux/3.9.4.60020/insync_3.9.4.60020-noble_amd64.deb"

    # Baixa o pacote
    log "Baixando Insync..."
    if ! wget "$INSYNC_URL" -O insync.deb; then
        error "Falha ao baixar o Insync"
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Instala o pacote
    log "Instalando Insync..."
    if ! dpkg -i insync.deb; then
        log "Instalando dependências..."
        apt-get install -f -y
    fi

    # Verifica se a instalação foi bem sucedida
    if command -v insync &> /dev/null; then
        log "Insync instalado com sucesso!"
        log "Para usar o Insync, execute: insync"
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        return 0
    else
        error "Falha ao instalar o Insync"
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        return 1
    fi
}

# Executa a instalação com os argumentos passados
install_insync "$1" 