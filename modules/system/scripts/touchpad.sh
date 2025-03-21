#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

configure_touchpad() {
    log "Configurando touchpad..."

    # Verifica se já foi configurado
    if [ -f "/usr/local/bin/configure-touchpad.sh" ] && [ -f "/etc/udev/rules.d/90-touchpad.rules" ]; then
        log "Touchpad já está configurado"
        return 0
    fi

    # Instala dependências necessárias
    log "Instalando dependências..."
    apt install -y xinput libinput-tools dconf-cli gsettings-desktop-schemas

    # Configura para o usuário atual (não root)
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    log "Aplicando configurações do touchpad para o usuário $CURRENT_USER..."

    # 1. Configuração via gsettings
    log "Aplicando configurações via gsettings..."
    sudo -u $CURRENT_USER dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false
    sudo -u $CURRENT_USER dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers'
    sudo -u $CURRENT_USER dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad send-events 'enabled'

    # 2. Configuração via dconf
    log "Aplicando configurações via dconf..."
    sudo -u $CURRENT_USER dbus-launch dconf write /org/gnome/desktop/peripherals/touchpad/tap-to-click false
    sudo -u $CURRENT_USER dbus-launch dconf write /org/gnome/desktop/peripherals/touchpad/click-method "'fingers'"

    # 3. Configuração via X11
    log "Criando configuração do X11..."
    local XORG_CONF_DIR="/usr/share/X11/xorg.conf.d"
    local TOUCHPAD_CONF="$XORG_CONF_DIR/90-touchpad.conf"
    
    mkdir -p "$XORG_CONF_DIR"
    cat > "$TOUCHPAD_CONF" << EOF
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "off"
        Option "ClickMethod" "clickfinger"
        Option "TappingButtonMap" "lrm"
EndSection
EOF

    # 4. Configuração imediata via xinput
    log "Aplicando configurações via xinput..."
    local TOUCHPAD_ID=$(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | cut -d'=' -f2)
    
    if [ ! -z "$TOUCHPAD_ID" ]; then
        xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 0
        xinput set-prop "$TOUCHPAD_ID" "libinput Click Method Enabled" 0 1
    fi

    # Cria arquivo de regras udev para persistência
    log "Criando regras udev..."
    cat > "/etc/udev/rules.d/90-touchpad.rules" << EOF
ACTION=="add|change", KERNEL=="event[0-9]*", SUBSYSTEM=="input", ATTR{name}=="*Touchpad*", RUN+="/usr/bin/xinput set-prop \$name 'libinput Tapping Enabled' 0"
ACTION=="add|change", KERNEL=="event[0-9]*", SUBSYSTEM=="input", ATTR{name}=="*Touchpad*", RUN+="/usr/bin/xinput set-prop \$name 'libinput Click Method Enabled' 0 1"
EOF

    log "Recarregando regras udev..."
    udevadm control --reload-rules
    udevadm trigger

    # Cria script de configuração
    local SCRIPT_PATH="/usr/local/bin/configure-touchpad.sh"
    cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
sleep 2  # Aguarda o sistema inicializar completamente
xinput set-prop "$(xinput list | grep -i touchpad | cut -d'=' -f2 | cut -f1)" "libinput Tapping Enabled" 0
xinput set-prop "$(xinput list | grep -i touchpad | cut -d'=' -f2 | cut -f1)" "libinput Click Method Enabled" 0 1
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers'
EOF

    chmod +x "$SCRIPT_PATH"

    # Cria arquivo de autostart atualizado
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
configure_touchpad 