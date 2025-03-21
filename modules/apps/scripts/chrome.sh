#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_chrome() {
    # Verifica se o Chrome já está instalado
    if dpkg -l | grep -q "google-chrome-stable"; then
        log "Google Chrome já está instalado"
        return 0
    fi

    log "Iniciando instalação do Google Chrome..."

    # Define variáveis
    local TEMP_DIR="/tmp/chrome-install"
    local DEB_FILE="$TEMP_DIR/chrome.deb"
    local CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

    # Cria diretório temporário
    mkdir -p "$TEMP_DIR"

    # Download do Chrome
    log "Baixando Google Chrome..."
    if wget -O "$DEB_FILE" "$CHROME_URL"; then
        log "Instalando dependências..."
        apt install -y gdebi-core

        log "Instalando Google Chrome..."
        if gdebi -n "$DEB_FILE"; then
            log "Google Chrome instalado com sucesso!"
            # Limpa arquivos temporários
            rm -rf "$TEMP_DIR"
            return 0
        else
            error "Falha ao instalar o Google Chrome"
            rm -rf "$TEMP_DIR"
            return 1
        fi
    else
        error "Falha ao baixar o Google Chrome"
        rm -rf "$TEMP_DIR"
        return 1
    fi
}

# Executa a instalação
install_chrome 