#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_dbeaver() {
    log "Instalando DBeaver..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Verifica se já está instalado e se não está em modo forçado
    if command -v dbeaver &> /dev/null && [ "$1" != "--force" ]; then
        log "DBeaver já está instalado"
        log "Use --force para reinstalar"
        return 0
    fi

    # Se estiver em modo forçado, remove a instalação anterior
    if [ "$1" == "--force" ]; then
        log "Modo forçado: removendo instalação anterior..."
        apt-get remove -y dbeaver-ce
        apt-get autoremove -y
        apt-get clean
        rm -rf ~/.dbeaver4
    fi

    # Atualiza os repositórios
    log "Atualizando repositórios..."
    apt-get update

    # Adiciona o repositório do DBeaver se não existir
    if [ ! -f "/etc/apt/sources.list.d/dbeaver.list" ]; then
        log "Adicionando repositório do DBeaver..."
        wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | apt-key add -
        echo "deb https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
        apt-get update
    fi

    # Instala o DBeaver Community Edition
    log "Instalando DBeaver Community Edition..."
    apt-get install -y dbeaver-ce

    # Verifica se a instalação foi bem sucedida
    if command -v dbeaver &> /dev/null; then
        log "DBeaver instalado com sucesso!"
        log "Para usar o DBeaver, execute: dbeaver"
        return 0
    else
        error "Falha ao instalar o DBeaver"
        return 1
    fi
}

# Executa a instalação com os argumentos passados
install_dbeaver "$1" 