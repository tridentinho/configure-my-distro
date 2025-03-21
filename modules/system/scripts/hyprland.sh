#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_hyprland() {
    local REINSTALL=false
    
    # Verifica se a flag de reinstalação foi passada
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --reinstall)
                REINSTALL=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Configura para o usuário atual (não root)
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    local USER_HOME="/home/$CURRENT_USER"
    local HYPR_DIR="$USER_HOME/Ubuntu-Hyprland-24.04"

    # Verifica se o Hyprland já está instalado
    if command -v hyprctl &> /dev/null && [ "$REINSTALL" = false ]; then
        log "Hyprland já está instalado. Use --reinstall para forçar a reinstalação."
        return 0
    fi

    # Verifica se o diretório já existe
    if [ -d "$HYPR_DIR" ]; then
        log "Removendo instalação anterior..."
        rm -rf "$HYPR_DIR"
    fi

    # Clona o repositório
    log "Clonando repositório do Hyprland..."
    sudo -u $CURRENT_USER git clone -b 24.04 --depth=1 https://github.com/JaKooLit/Ubuntu-Hyprland.git "$HYPR_DIR"

    if [ $? -ne 0 ]; then
        error "Falha ao clonar o repositório"
        return 1
    fi

    # Configura permissões e executa o script de instalação
    log "Configurando permissões..."
    chmod +x "$HYPR_DIR/install.sh"

    log "Iniciando instalação do Hyprland..."
    log "Este processo pode demorar alguns minutos..."
    log "Por favor, siga as instruções na tela"
    
    # Executa o script de instalação como usuário normal
    cd "$HYPR_DIR"
    sudo -u $CURRENT_USER ./install.sh

    if [ $? -ne 0 ]; then
        error "Falha durante a instalação do Hyprland"
        return 1
    fi

    log "Instalação do Hyprland concluída!"
    log "Por favor, reinicie o sistema para aplicar todas as alterações."
}

# Executa a instalação
install_hyprland "$@"