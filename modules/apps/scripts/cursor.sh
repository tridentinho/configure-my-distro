#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_cursor() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local APPS_DIR="$USER_HOME/Applications"
    local CURSOR_PATH="$APPS_DIR/Cursor.AppImage"

    # Verifica se o Cursor já está instalado
    if [ -x "$CURSOR_PATH" ]; then
        log "Cursor já está instalado em $CURSOR_PATH"
        return 0
    fi

    log "Iniciando instalação do Cursor..."

    # Instala dependências
    apt install -y libfuse2

    # Cria diretório de Applications se não existir
    mkdir -p "$APPS_DIR"

    # Download do Cursor
    local CURSOR_URL="https://downloads.cursor.com/production/82ef0f61c01d079d1b7e5ab04d88499d5af500e3/linux/x64/Cursor-0.47.8-82ef0f61c01d079d1b7e5ab04d88499d5af500e3.deb.glibc2.25-x86_64.AppImage"
    
    log "Baixando Cursor..."
    if wget -O "$CURSOR_PATH" "$CURSOR_URL"; then
        chmod +x "$CURSOR_PATH"
        chown ${SUDO_USER}:${SUDO_USER} "$CURSOR_PATH"
        log "Cursor instalado com sucesso!"
        return 0
    else
        error "Falha ao baixar o Cursor"
        return 1
    fi
}

create_desktop_entry() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local DESKTOP_FILE="$USER_HOME/.local/share/applications/cursor.desktop"    
    local APPS_DIR="$USER_HOME/Applications"
    local CURSOR_PATH="$APPS_DIR/Cursor.AppImage"

    # Cria diretório .local/share/applications se não existir
    mkdir -p "$(dirname "$DESKTOP_FILE")"

    # Verifica se o desktop entry já existe
    if [ -f "$DESKTOP_FILE" ]; then
        log "Desktop entry já existe em $DESKTOP_FILE"
        return 0
    fi

    # Tenta baixar o icone
    if wget -O "$APPS_DIR/cursor.png" "https://custom.typingmind.com/assets/models/cursor.png"; then
        local ICON_PATH="$APPS_DIR/cursor.png"
        chown ${SUDO_USER}:${SUDO_USER} "$ICON_PATH"
    else
        error "Não foi possível baixar o icone"
        local ICON_PATH="$CURSOR_PATH"
    fi

    # Cria o arquivo desktop
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Cursor
Exec=$CURSOR_PATH --no-sandbox&
Icon=$ICON_PATH
Type=Application
Categories=Development;IDE
EOF

    # Ajusta as permissões do arquivo .desktop
    chown ${SUDO_USER}:${SUDO_USER} "$DESKTOP_FILE"
    chmod 644 "$DESKTOP_FILE"
}

# Executa a instalação
install_cursor 
create_desktop_entry