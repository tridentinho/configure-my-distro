#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/scripts/common.sh"

# Diretório dos scripts de sistema
SYSTEM_SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")/scripts"

log "Iniciando configurações do sistema..."

# Instala o git se não estiver instalado
if ! command -v git &> /dev/null; then
    log "Instalando git..."
    apt-get install -y git
fi

# Lista de configurações do sistema (ordem de dependência)
configs=(
    "git"
    "ssh_min"
    "hyprland"  # Primeiro instala o Hyprland
    "touchpad"  # Depois configura o touchpad
    "envs"  # Configura variáveis de ambiente e aliases
    "docker"  # Instala Docker CLI e Docker Compose
    # Adicione mais configurações aqui
)

# Função para aplicar uma configuração específica
apply_config() {
    local config_script="$SYSTEM_SCRIPTS_DIR/$1.sh"
    if [ -f "$config_script" ]; then
        log "Aplicando configuração: $1..."
        if bash "$config_script"; then
            log "Configuração $1 aplicada com sucesso!"
        else
            error "Falha ao aplicar configuração $1"
        fi
    else
        error "Script de configuração não encontrado para $1"
    fi
}

# Aplica cada configuração
for config in "${configs[@]}"; do
    apply_config "$config"
done

log "Configurações do sistema concluídas!"