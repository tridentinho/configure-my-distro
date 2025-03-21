#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_remmina() {
    log "Instalando Remmina..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Verifica se já está instalado e se não está em modo forçado
    if command -v remmina &> /dev/null && [ "$1" != "--force" ]; then
        log "Remmina já está instalado"
        log "Use --force para reinstalar"
        return 0
    fi

    # Se estiver em modo forçado, remove a instalação anterior
    if [ "$1" == "--force" ]; then
        log "Modo forçado: removendo instalação anterior..."
        apt-get remove -y remmina remmina-common
        apt-get autoremove -y
        apt-get clean
    fi

    # Atualiza os repositórios
    log "Atualizando repositórios..."
    apt-get update

    # Instala o Remmina e plugins
    log "Instalando Remmina e plugins..."
    apt-get install -y remmina remmina-common \
        remmina-plugin-rdp \
        remmina-plugin-vnc \
        remmina-plugin-secret \
        remmina-plugin-spice \
        remmina-plugin-www \
        remmina-plugin-exec

    # Verifica se a instalação foi bem sucedida
    if command -v remmina &> /dev/null; then
        log "Remmina instalado com sucesso!"
        log "Para usar o Remmina, execute: remmina"
        return 0
    else
        error "Falha ao instalar o Remmina"
        return 1
    fi
}

# Executa a instalação com os argumentos passados
install_remmina "$1" 