#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/scripts/common.sh"

# Diretório dos scripts de apps
APPS_SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")/scripts"

log "Iniciando instalação de aplicativos..."

# Lista de apps para instalar
apps=(
    "cursor"
    "chrome"
    # Adicione mais apps aqui
    # "vscode"
    # etc...
)

# Função para instalar um app específico
install_app() {
    local app_script="$APPS_SCRIPTS_DIR/$1.sh"
    if [ -f "$app_script" ]; then
        log "Instalando $1..."
        if bash "$app_script"; then
            log "Instalação de $1 concluída com sucesso!"
        else
            error "Falha na instalação de $1"
        fi
    else
        error "Script de instalação não encontrado para $1"
    fi
}

# Instala cada app da lista
for app in "${apps[@]}"; do
    install_app "$app"
done

log "Instalação de aplicativos concluída!" 