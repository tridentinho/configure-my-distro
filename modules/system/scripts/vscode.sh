#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_vscode() {
    log "Instalando Visual Studio Code..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Verifica se já está instalado e se não está em modo forçado
    if command -v code &> /dev/null && [ "$1" != "--force" ]; then
        log "Visual Studio Code já está instalado"
        log "Use --force para reinstalar"
        return 0
    fi

    # Se estiver em modo forçado, remove a instalação anterior
    if [ "$1" == "--force" ]; then
        log "Modo forçado: removendo instalação anterior..."
        apt-get remove -y code
        apt-get autoremove -y
        apt-get clean
        rm -rf ~/.config/Code
        rm -rf ~/.vscode
    fi

    # Atualiza os repositórios
    log "Atualizando repositórios..."
    apt-get update

    # Adiciona o repositório do VSCode se não existir
    if [ ! -f "/etc/apt/sources.list.d/vscode.list" ]; then
        log "Adicionando repositório do Visual Studio Code..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        apt-get update
    fi

    # Instala o VSCode
    log "Instalando Visual Studio Code..."
    apt-get install -y code

    # Instala extensões recomendadas
    log "Instalando extensões recomendadas..."
    sudo -u $CURRENT_USER code --install-extension ms-vscode.cpptools
    sudo -u $CURRENT_USER code --install-extension dbaeumer.vscode-eslint
    sudo -u $CURRENT_USER code --install-extension esbenp.prettier-vscode
    sudo -u $CURRENT_USER code --install-extension ms-python.python
    sudo -u $CURRENT_USER code --install-extension ms-python.vscode-pylance
    sudo -u $CURRENT_USER code --install-extension golang.go
    sudo -u $CURRENT_USER code --install-extension rust-lang.rust-analyzer
    sudo -u $CURRENT_USER code --install-extension bradlc.vscode-tailwindcss
    sudo -u $CURRENT_USER code --install-extension ms-vscode.vscode-typescript-next
    sudo -u $CURRENT_USER code --install-extension eamodio.gitlens

    # Verifica se a instalação foi bem sucedida
    if command -v code &> /dev/null; then
        log "Visual Studio Code instalado com sucesso!"
        log "Para usar o VSCode, execute: code"
        return 0
    else
        error "Falha ao instalar o Visual Studio Code"
        return 1
    fi
}

# Executa a instalação com os argumentos passados
install_vscode "$1" 