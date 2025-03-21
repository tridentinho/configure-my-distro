#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/scripts/common.sh"

# Diretório dos scripts de aplicativos
APPS_SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")/scripts"

log "Iniciando instalação de aplicativos..."

# Lista de aplicativos a serem instalados
apps=(
    "chrome"  # Instala o Google Chrome
    "dbeaver"  # Instala o DBeaver
    "forticlient"  # Instala o FortiClient VPN
    "insync"  # Instala o Insync
    "remmina"  # Instala o Remmina
    "vscode"  # Instala o Visual Studio Code
    # Adicione mais aplicativos aqui
)

# Função para instalar um aplicativo específico
install_app() {
    local app_script="$APPS_SCRIPTS_DIR/$1.sh"
    if [ -f "$app_script" ]; then
        log "Instalando aplicativo: $1..."
        if bash "$app_script"; then
            log "Aplicativo $1 instalado com sucesso!"
        else
            error "Falha ao instalar aplicativo $1"
        fi
    else
        error "Script de instalação não encontrado para $1"
    fi
}

# Instala cada aplicativo
for app in "${apps[@]}"; do
    install_app "$app"
done

log "Instalação de aplicativos concluída!" 