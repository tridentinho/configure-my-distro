#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

configure_touchpad() {
    log "Configurando touchpad..."

    # Verifica se o Hyprland está instalado
    if ! command -v hyprctl &> /dev/null; then
        error "Hyprland não está instalado. Por favor, instale o Hyprland primeiro."
        return 1
    fi

    # Verifica se já foi configurado e se não está em modo forçado
    if [ -f "/usr/local/bin/configure-touchpad.sh" ] && [ -f "/etc/udev/rules.d/90-touchpad.rules" ] && [ "$1" != "--force" ]; then
        log "Touchpad já está configurado"
        log "Use --force para reconfigurar"
        return 0
    fi

    # Se estiver em modo forçado, remove configurações anteriores
    if [ "$1" == "--force" ]; then
        log "Modo forçado: removendo configurações anteriores..."
        rm -f "/usr/local/bin/configure-touchpad.sh"
        rm -f "/etc/udev/rules.d/90-touchpad.rules"
        rm -f "/etc/libinput/local-overrides.quirks"
    fi

    # Instala dependências necessárias
    log "Instalando dependências..."
    apt install -y libinput-tools

    # Configura para o usuário atual (não root)
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    log "Aplicando configurações do touchpad para o usuário $CURRENT_USER..."

    # 1. Configuração via Hyprland
    log "Aplicando configurações via Hyprland..."
    local HYPR_CONFIG_DIR="/home/$CURRENT_USER/.config/hypr"
    mkdir -p "$HYPR_CONFIG_DIR"

    # Adiciona configurações do touchpad ao arquivo de configuração do Hyprland
    cat >> "$HYPR_CONFIG_DIR/hyprland.conf" << EOF

# Configurações do Touchpad
input {
    kb_layout = br
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1
    touchpad {
        natural_scroll = true
        disable_while_typing = true
        tap-to-click = false
        clickfinger_behavior = true
        middle_button_emulation = false
        tap_button_map = lrm
    }
    sensitivity = 0
}
EOF

    # 2. Configuração via libinput
    log "Criando configuração do libinput..."
    local LIBINPUT_CONF_DIR="/etc/libinput"
    mkdir -p "$LIBINPUT_CONF_DIR"
    
    cat > "$LIBINPUT_CONF_DIR/local-overrides.quirks" << EOF
[Touchpad]
MatchUdevType=touchpad
AttrTappingEnabled=0
AttrClickMethod=1
AttrTappingButtonMap=1
AttrNaturalScrollingEnabled=1
EOF

    # 3. Configuração via udev
    log "Criando regras udev..."
    cat > "/etc/udev/rules.d/90-touchpad.rules" << EOF
ACTION=="add|change", KERNEL=="event[0-9]*", SUBSYSTEM=="input", ATTR{name}=="*Touchpad*", ENV{LIBINPUT_DEVICE_GROUP}="touchpad"
EOF

    log "Recarregando regras udev..."
    udevadm control --reload-rules
    udevadm trigger

    # Cria script de configuração
    local SCRIPT_PATH="/usr/local/bin/configure-touchpad.sh"
    cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
sleep 2  # Aguarda o sistema inicializar completamente

# Configura o touchpad via libinput
for device in $(libinput list-devices | grep -A1 "Touchpad" | grep -o "event[0-9]*"); do
    libinput-device-calibrate "/dev/input/$device"
done

# Recarrega as configurações do Hyprland
hyprctl reload
EOF

    chmod +x "$SCRIPT_PATH"

    # Cria arquivo de autostart
    create_autostart "$SCRIPT_PATH"

    log "Configuração do touchpad concluída!"
    log "Por favor, reinicie o sistema para aplicar todas as configurações."
}

# Função para criar arquivo de autostart
create_autostart() {
    local SCRIPT_PATH="$1"
    local CURRENT_USER=$SUDO_USER
    local AUTOSTART_DIR="/home/$CURRENT_USER/.config/autostart"
    local AUTOSTART_FILE="$AUTOSTART_DIR/touchpad-settings.desktop"

    # Cria diretório autostart se não existir
    sudo -u $CURRENT_USER mkdir -p "$AUTOSTART_DIR"

    # Cria arquivo .desktop
    cat > "$AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Touchpad Settings
Exec=$SCRIPT_PATH
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

    # Ajusta as permissões
    chown $CURRENT_USER:$CURRENT_USER "$AUTOSTART_FILE"
    chmod +x "$AUTOSTART_FILE"
}

# Executa as configurações
configure_touchpad "$1"