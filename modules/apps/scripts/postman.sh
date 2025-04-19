#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

uninstall_postman() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local APPS_DIR="$USER_HOME/Applications"
    local POSTMAN_DIR="$APPS_DIR/Postman"
    local DESKTOP_FILE="$USER_HOME/.local/share/applications/postman.desktop"
    local ICON_PATH="$APPS_DIR/postman.png"

    log "Removendo instalação existente do Postman..."
    
    # Remove o diretório do Postman
    if [ -d "$POSTMAN_DIR" ]; then
        rm -rf "$POSTMAN_DIR"
        log "Diretório do Postman removido."
    fi
    
    # Remove o ícone
    if [ -f "$ICON_PATH" ]; then
        rm -f "$ICON_PATH"
        log "Ícone do Postman removido."
    fi
    
    # Remove o arquivo desktop
    if [ -f "$DESKTOP_FILE" ]; then
        rm -f "$DESKTOP_FILE"
        log "Entrada desktop do Postman removida."
    fi
    
    log "Desinstalação do Postman concluída."
}

install_postman() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local APPS_DIR="$USER_HOME/Applications"
    local POSTMAN_DIR="$APPS_DIR/Postman"
    local POSTMAN_EXEC="$POSTMAN_DIR/Postman"

    # Verifica se o Postman já está instalado
    if [ -x "$POSTMAN_EXEC" ] && [ "$1" != "--reinstall" ]; then
        log "Postman já está instalado em $POSTMAN_EXEC"
        return 0
    fi

    log "Iniciando instalação do Postman..."

    # Instala dependências
    apt install -y libfuse2 libgconf-2-4 libxss1 libgtk-3-0

    # Cria diretório de Applications se não existir
    mkdir -p "$APPS_DIR"
    
    # Define URL do Postman (página oficial para obter a versão mais recente)
    local POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"
    
    log "Baixando Postman..."
    
    # Baixa o Postman para um arquivo temporário
    local TEMP_FILE="/tmp/postman-temp.tar.gz"
    if wget -O "$TEMP_FILE" "$POSTMAN_URL"; then
        log "Download concluído, extraindo arquivos..."
        
        # Remove instalação existente se houver
        if [ -d "$POSTMAN_DIR" ]; then
            rm -rf "$POSTMAN_DIR"
        fi
        
        # Extrai o arquivo baixado diretamente para o diretório Applications
        tar -xzf "$TEMP_FILE" -C "$APPS_DIR"
        
        # Verifica se a extração foi bem-sucedida
        if [ -d "$POSTMAN_DIR" ]; then
            # Ajusta as permissões
            chmod +x "$POSTMAN_EXEC"
            chown -R ${SUDO_USER}:${SUDO_USER} "$POSTMAN_DIR"
            
            # Copia o ícone
            if [ -f "$POSTMAN_DIR/app/resources/app/assets/icon.png" ]; then
                cp "$POSTMAN_DIR/app/resources/app/assets/icon.png" "$APPS_DIR/postman.png"
                chown ${SUDO_USER}:${SUDO_USER} "$APPS_DIR/postman.png"
            fi
            
            # Limpa o arquivo temporário
            rm -f "$TEMP_FILE"
            
            log "Postman instalado com sucesso!"
            return 0
        else
            error "Falha ao extrair o Postman"
            rm -f "$TEMP_FILE"
            return 1
        fi
    else
        error "Falha ao baixar o Postman"
        return 1
    fi
}

create_desktop_entry() {
    local USER_HOME=$(eval echo ~${SUDO_USER})
    local DESKTOP_FILE="$USER_HOME/.local/share/applications/postman.desktop"    
    local APPS_DIR="$USER_HOME/Applications"
    local POSTMAN_EXEC="$APPS_DIR/Postman/Postman"
    local ICON_PATH="$APPS_DIR/postman.png"

    # Cria diretório .local/share/applications se não existir
    mkdir -p "$(dirname "$DESKTOP_FILE")"

    # Se o ícone não existe, tenta baixá-lo
    if [ ! -f "$ICON_PATH" ]; then
        log "Baixando ícone do Postman..."
        if wget -O "$ICON_PATH" "https://www.vectorlogo.zone/logos/getpostman/getpostman-icon.svg"; then
            chown ${SUDO_USER}:${SUDO_USER} "$ICON_PATH"
        else
            error "Não foi possível baixar o ícone"
            ICON_PATH="$POSTMAN_EXEC"
        fi
    fi

    # Cria o arquivo desktop
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Postman
Exec="$POSTMAN_EXEC"
Icon=$ICON_PATH
Type=Application
Categories=Development;Network;
Comment=API Development Environment
Terminal=false
StartupWMClass=Postman
EOF

    # Ajusta as permissões do arquivo .desktop
    chown ${SUDO_USER}:${SUDO_USER} "$DESKTOP_FILE"
    chmod 644 "$DESKTOP_FILE"
    
    log "Entrada desktop criada com sucesso."
}

# Processa argumentos da linha de comando
if [ "$1" = "--reinstall" ]; then
    log "Iniciando reinstalação do Postman..."
    uninstall_postman
fi

# Executa a instalação
install_postman "$1"
create_desktop_entry 