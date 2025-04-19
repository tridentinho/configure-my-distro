#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

uninstall_notion() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local APPS_DIR="$USER_HOME/Applications"
    local NOTION_PATH="$APPS_DIR/Notion.AppImage"
    local DESKTOP_FILE="$USER_HOME/.local/share/applications/notion.desktop"
    local ICON_PATH="$APPS_DIR/notion.png"

    log "Removendo instalação existente do Notion..."
    
    # Remove o arquivo AppImage
    if [ -f "$NOTION_PATH" ]; then
        rm -f "$NOTION_PATH"
        log "Arquivo AppImage do Notion removido."
    fi
    
    # Remove o ícone
    if [ -f "$ICON_PATH" ]; then
        rm -f "$ICON_PATH"
        log "Ícone do Notion removido."
    fi
    
    # Remove o arquivo desktop
    if [ -f "$DESKTOP_FILE" ]; then
        rm -f "$DESKTOP_FILE"
        log "Entrada desktop do Notion removida."
    fi
    
    log "Desinstalação do Notion concluída."
}

install_notion() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local APPS_DIR="$USER_HOME/Applications"
    local NOTION_PATH="$APPS_DIR/Notion.AppImage"

    # Verifica se o Notion já está instalado
    if [ -x "$NOTION_PATH" ] && [ "$1" != "--reinstall" ]; then
        log "Notion já está instalado em $NOTION_PATH"
        return 0
    fi

    log "Iniciando instalação do Notion..."

    # Instala dependências
    apt install -y libfuse2

    # Cria diretório de Applications se não existir
    mkdir -p "$APPS_DIR"
    
    # Define URL do Notion
    local NOTION_URL="https://desktop-release.notion-static.com/Notion-2.3.32.AppImage"
    
    log "Baixando Notion..."
    if wget -O "$NOTION_PATH" "$NOTION_URL"; then
        chmod +x "$NOTION_PATH"
        chown ${SUDO_USER}:${SUDO_USER} "$NOTION_PATH"
        log "Notion instalado com sucesso!"
        return 0
    else
        error "Falha ao baixar o Notion"
        return 1
    fi
}

create_desktop_entry() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local DESKTOP_FILE="$USER_HOME/.local/share/applications/notion.desktop"    
    local APPS_DIR="$USER_HOME/Applications"
    local NOTION_PATH="$APPS_DIR/Notion.AppImage"
    local ICON_PATH="$APPS_DIR/notion.png"

    # Cria diretório .local/share/applications se não existir
    mkdir -p "$(dirname "$DESKTOP_FILE")"

    # Verifica se o desktop entry já existe
    if [ -f "$DESKTOP_FILE" ]; then
        log "Desktop entry já existe em $DESKTOP_FILE"
        return 0
    fi

    # Baixa o ícone
    log "Baixando ícone do Notion..."
    if wget -O "$ICON_PATH" "https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png"; then
        chown ${SUDO_USER}:${SUDO_USER} "$ICON_PATH"
    else
        error "Não foi possível baixar o ícone"
        ICON_PATH="$NOTION_PATH"
    fi

    # Cria o arquivo desktop
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Notion
Exec=$NOTION_PATH --no-sandbox
Icon=$ICON_PATH
Type=Application
Categories=Office;Productivity;
Comment=All-in-one workspace
Terminal=false
StartupWMClass=Notion
EOF

    # Ajusta as permissões do arquivo .desktop
    chown ${SUDO_USER}:${SUDO_USER} "$DESKTOP_FILE"
    chmod 644 "$DESKTOP_FILE"
    
    log "Entrada desktop criada com sucesso."
}

# Processa argumentos da linha de comando
if [ "$1" = "--reinstall" ]; then
    log "Iniciando reinstalação do Notion..."
    uninstall_notion
fi

# Executa a instalação
install_notion "$1"
create_desktop_entry 