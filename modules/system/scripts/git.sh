#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

configure_git() {
    log "Configurando Git..."

    # Configura para o usuário atual (não root)
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    local USER_HOME="/home/$CURRENT_USER"

    # Verifica se o git já está configurado
    if sudo -u $CURRENT_USER git config --global user.name > /dev/null && \
       sudo -u $CURRENT_USER git config --global user.email > /dev/null; then
        log "Git já está configurado"
        return 0
    fi

    # Solicita informações do usuário
    log "Por favor, insira suas informações do Git:"
    
    # Solicita nome
    read -p "Nome completo: " GIT_NAME
    while [ -z "$GIT_NAME" ]; do
        error "O nome não pode estar vazio"
        read -p "Nome completo: " GIT_NAME
    done

    # Solicita email
    read -p "Email: " GIT_EMAIL
    while [ -z "$GIT_EMAIL" ]; do
        error "O email não pode estar vazio"
        read -p "Email: " GIT_EMAIL
    done

    # Valida formato do email
    if ! echo "$GIT_EMAIL" | grep -E "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$" > /dev/null; then
        error "Email inválido"
        return 1
    fi

    # Configura o Git globalmente
    log "Configurando Git com suas informações..."
    sudo -u $CURRENT_USER git config --global user.name "$GIT_NAME"
    sudo -u $CURRENT_USER git config --global user.email "$GIT_EMAIL"

    # Configurações adicionais recomendadas
    log "Configurando opções adicionais do Git..."
    sudo -u $CURRENT_USER git config --global core.editor "nano"
    sudo -u $CURRENT_USER git config --global init.defaultBranch "main"
    sudo -u $CURRENT_USER git config --global pull.rebase false
    sudo -u $CURRENT_USER git config --global push.autoSetupRemote true
    sudo -u $CURRENT_USER git config --global core.filemode false

    # Mostra as configurações
    log "Configurações do Git:"
    sudo -u $CURRENT_USER git config --global --list

    log "Configuração do Git concluída!"
}

# Executa a configuração
configure_git 