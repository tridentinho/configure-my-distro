#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_node_dev() {
    log "Instalando ferramentas de desenvolvimento Node.js..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Verifica instalações individuais
    local FORCE_MODE="$1"
    local NEED_INSTALL=false

    # Carrega NVM se existir
    export NVM_DIR="/home/$CURRENT_USER/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
    fi

    # Verifica NVM
    if [ ! -d "/home/$CURRENT_USER/.nvm" ] || [ "$FORCE_MODE" == "--force" ]; then
        NEED_INSTALL=true
        log "NVM não encontrado ou modo forçado ativado"
    fi

    # Verifica Node.js
    if ! sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && node --version" &>/dev/null || [ "$FORCE_MODE" == "--force" ]; then
        NEED_INSTALL=true
        log "Node.js não encontrado ou modo forçado ativado"
    fi

    # Verifica Yarn
    if ! sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && yarn --version" &>/dev/null || [ "$FORCE_MODE" == "--force" ]; then
        NEED_INSTALL=true
        log "Yarn não encontrado ou modo forçado ativado"
    fi

    # Verifica NestJS CLI
    if ! sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && nest --version" &>/dev/null || [ "$FORCE_MODE" == "--force" ]; then
        NEED_INSTALL=true
        log "NestJS CLI não encontrado ou modo forçado ativado"
    fi

    # Verifica Create Next App
    if ! sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && create-next-app --version" &>/dev/null || [ "$FORCE_MODE" == "--force" ]; then
        NEED_INSTALL=true
        log "Create Next App não encontrado ou modo forçado ativado"
    fi

    # Se não precisar instalar, retorna
    if [ "$NEED_INSTALL" = false ]; then
        log "Todas as ferramentas Node.js já estão instaladas"
        return 0
    fi

    # Se estiver em modo forçado, remove a instalação anterior
    if [ "$FORCE_MODE" == "--force" ]; then
        log "Modo forçado: removendo instalação anterior..."
        rm -rf "/home/$CURRENT_USER/.nvm"
        apt-get remove -y nodejs npm
        apt-get autoremove -y
        apt-get clean
    fi

    # Instala dependências necessárias
    log "Instalando dependências..."
    apt-get install -y curl git

    # Instala NVM
    log "Instalando NVM..."
    sudo -u $CURRENT_USER curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | sudo -u $CURRENT_USER bash

    # Configura NVM no .zshrc
    local ZSHRC="/home/$CURRENT_USER/.zshrc"
    if ! grep -q "NVM_DIR" "$ZSHRC"; then
        echo -e "\n# NVM Configuration" >> "$ZSHRC"
        echo 'export NVM_DIR="$HOME/.nvm"' >> "$ZSHRC"
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$ZSHRC"
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$ZSHRC"
    fi

    # Carrega NVM
    export NVM_DIR="/home/$CURRENT_USER/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Instala Node.js 20 LTS via NVM
    log "Instalando Node.js 20 LTS..."
    sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && nvm install 20 && nvm use 20 && nvm alias default 20"

    # Recarrega o ZSH
    log "Recarregando ZSH..."
    sudo -u $CURRENT_USER zsh -c "source $ZSHRC"

    # Instala Yarn globalmente
    log "Instalando Yarn..."
    sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && npm install -g yarn"

    # Instala NestJS CLI globalmente
    log "Instalando NestJS CLI..."
    sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && npm install -g @nestjs/cli"

    # Instala Create Next App globalmente
    log "Instalando Create Next App..."
    sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && npm install -g create-next-app"

    # Verifica a instalação
    local NODE_VERSION=$(sudo -u $CURRENT_USER bash -c "source $NVM_DIR/nvm.sh && node --version")
    
    if [ -n "$NODE_VERSION" ]; then
        log "Node.js instalado com sucesso!"
        log "Versão instalada: $NODE_VERSION"
        return 0
    else
        error "Falha ao instalar Node.js"
        return 1
    fi
}

# Executa a instalação com os argumentos passados
install_node_dev "$1"