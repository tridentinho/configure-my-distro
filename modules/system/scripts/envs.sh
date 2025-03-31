#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

configure_envs() {
    log "Configurando variáveis de ambiente e aliases..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Define o arquivo de configuração do shell
    local SHELL_CONFIG="/home/$CURRENT_USER/.zshrc"
    local BACKUP_FILE="$SHELL_CONFIG.backup"

    # Cria backup do arquivo de configuração
    if [ ! -f "$BACKUP_FILE" ]; then
        log "Criando backup do arquivo de configuração..."
        cp "$SHELL_CONFIG" "$BACKUP_FILE"
    fi

    # Define os aliases a serem adicionados
    declare -A ALIASES=(
        ["cursor"]='$HOME/Applications/Cursor.AppImage --no-sandbox --disable-gpu $@'
    )

    # Define as variáveis de ambiente a serem adicionadas
    declare -A ENVS=(
        ["XDG_DATA_DIRS"]='/usr/share:/usr/local/share'
    )

    # Função para adicionar configuração se não existir
    add_config_if_not_exists() {
        local config="$1"
        local comment="$2"
        
        if ! grep -q "$config" "$SHELL_CONFIG"; then
            log "Adicionando $comment..."
            echo -e "\n# $comment" >> "$SHELL_CONFIG"
            echo "$config" >> "$SHELL_CONFIG"
        else
            log "$comment já está configurado"
        fi
    }

    # Adiciona aliases
    for alias_name in "${!ALIASES[@]}"; do
        add_config_if_not_exists "alias $alias_name='${ALIASES[$alias_name]}'" "Alias para $alias_name"
    done

    # Adiciona variáveis de ambiente
    for env_name in "${!ENVS[@]}"; do
        add_config_if_not_exists "export $env_name=${ENVS[$env_name]}" "Variável de ambiente $env_name"
    done

    # Recarrega as configurações do shell
    log "Recarregando configurações do shell..."
    source "$SHELL_CONFIG"

    log "Configurações de ambiente e aliases concluídas!"
    return 0
}

# Executa a configuração
configure_envs 