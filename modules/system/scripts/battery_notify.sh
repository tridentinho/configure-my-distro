#!/bin/bash

# Script para configurar notificações de bateria no Hyprland
# Verifica níveis de 20%, 15%, 10% e 5% apenas quando desconectado da tomada

# Diretório de configuração do Hyprland
HYPR_CONFIG_DIR="$HOME/.config/hypr"
BATTERY_SCRIPT="$HYPR_CONFIG_DIR/scripts/battery-notify.sh"
SOUNDS_DIR="$HYPR_CONFIG_DIR/sounds"

# Cria diretórios necessários
mkdir -p "$HYPR_CONFIG_DIR/scripts"
mkdir -p "$SOUNDS_DIR"

# Baixa sons de notificação se não existirem
if [ ! -f "$SOUNDS_DIR/battery-low.wav" ]; then
    echo "Baixando sons de notificação..."
    wget -q https://github.com/daniruiz/flat-remix-gnome/raw/master/sounds/budgie/battery-low.oga -O "$SOUNDS_DIR/battery-low.wav"
    wget -q https://github.com/daniruiz/flat-remix-gnome/raw/master/sounds/budgie/battery-full.oga -O "$SOUNDS_DIR/battery-full.wav"
    wget -q https://github.com/daniruiz/flat-remix-gnome/raw/master/sounds/budgie/dialog-warning.oga -O "$SOUNDS_DIR/warning.wav"
    wget -q https://github.com/daniruiz/flat-remix-gnome/raw/master/sounds/budgie/desktop-login.oga -O "$SOUNDS_DIR/notification.wav"
fi

# Cria o script de notificação de bateria
cat > "$BATTERY_SCRIPT" << 'EOF'
#!/bin/bash

# Script para monitorar níveis de bateria e enviar notificações
# Roda como serviço em segundo plano

# Diretório de sons
SOUNDS_DIR="$HOME/.config/hypr/sounds"

# Função para obter o nível atual da bateria
get_battery_level() {
    # Verifica se a bateria existe
    if [ -d "/sys/class/power_supply/BAT0" ]; then
        cat /sys/class/power_supply/BAT0/capacity
    elif [ -d "/sys/class/power_supply/BAT1" ]; then
        cat /sys/class/power_supply/BAT1/capacity
    else
        echo "100" # Sem bateria, retorna 100%
    fi
}

# Função para verificar se está conectado à tomada
is_on_ac_power() {
    if [ -d "/sys/class/power_supply/AC" ]; then
        [ "$(cat /sys/class/power_supply/AC/online)" -eq "1" ] && return 0 || return 1
    elif [ -d "/sys/class/power_supply/AC0" ]; then
        [ "$(cat /sys/class/power_supply/AC0/online)" -eq "1" ] && return 0 || return 1
    elif [ -d "/sys/class/power_supply/ACAD" ]; then
        [ "$(cat /sys/class/power_supply/ACAD/online)" -eq "1" ] && return 0 || return 1
    else
        # Não conseguiu determinar, assume que está na tomada
        return 0
    fi
}

# Variáveis para controle de notificações já enviadas
NOTIFIED_20=false
NOTIFIED_15=false
NOTIFIED_10=false
NOTIFIED_5=false

# Função para enviar notificação
send_battery_notification() {
    level=$1
    sound_file=$2
    urgency=$3
    
    notify-send "Bateria com $level%" "Conecte o carregador!" \
        --icon=battery-caution \
        --urgency=$urgency \
        --hint=int:transient:1
    
    # Reproduz o som de alerta
    paplay "$sound_file" &
}

# Loop principal
while true; do
    # Verifica se está na bateria (não conectado à tomada)
    if ! is_on_ac_power; then
        # Obtém o nível atual da bateria
        BATTERY_LEVEL=$(get_battery_level)
        
        # Verifica cada limiar e envia notificação se necessário
        if [ "$BATTERY_LEVEL" -le 5 ] && [ "$NOTIFIED_5" = false ]; then
            send_battery_notification "5" "$SOUNDS_DIR/warning.wav" "critical"
            NOTIFIED_5=true
        elif [ "$BATTERY_LEVEL" -le 10 ] && [ "$BATTERY_LEVEL" -gt 5 ] && [ "$NOTIFIED_10" = false ]; then
            send_battery_notification "10" "$SOUNDS_DIR/battery-low.wav" "critical"
            NOTIFIED_10=true
        elif [ "$BATTERY_LEVEL" -le 15 ] && [ "$BATTERY_LEVEL" -gt 10 ] && [ "$NOTIFIED_15" = false ]; then
            send_battery_notification "15" "$SOUNDS_DIR/battery-low.wav" "normal"
            NOTIFIED_15=true
        elif [ "$BATTERY_LEVEL" -le 20 ] && [ "$BATTERY_LEVEL" -gt 15 ] && [ "$NOTIFIED_20" = false ]; then
            send_battery_notification "20" "$SOUNDS_DIR/notification.wav" "low"
            NOTIFIED_20=true
        fi
        
        # Reseta as notificações quando a bateria sobe novamente
        if [ "$BATTERY_LEVEL" -gt 20 ]; then
            NOTIFIED_20=false
            NOTIFIED_15=false
            NOTIFIED_10=false
            NOTIFIED_5=false
        fi
    else
        # Reseta as notificações quando conectado à tomada
        NOTIFIED_20=false
        NOTIFIED_15=false
        NOTIFIED_10=false
        NOTIFIED_5=false
    fi
    
    # Verifica a cada 60 segundos
    sleep 60
done
EOF

# Torna o script executável
chmod +x "$BATTERY_SCRIPT"

# Adiciona ao arquivo de configuração do Hyprland se ainda não existir
HYPR_CONFIG_FILE="$HYPR_CONFIG_DIR/hyprland.conf"

if [ ! -f "$HYPR_CONFIG_FILE" ]; then
    touch "$HYPR_CONFIG_FILE"
fi

# Verifica se a configuração já existe
if ! grep -q "battery-notify.sh" "$HYPR_CONFIG_FILE"; then
    echo -e "\n# Executa script de notificação de bateria" >> "$HYPR_CONFIG_FILE"
    echo "exec-once = $BATTERY_SCRIPT" >> "$HYPR_CONFIG_FILE"
    echo "Configuração adicionada ao Hyprland!"
else
    echo "Configuração de notificação já existente no Hyprland."
fi

# Instala dependências necessárias
if ! command -v notify-send &> /dev/null || ! command -v paplay &> /dev/null; then
    echo "Instalando dependências necessárias..."
    sudo apt-get update
    sudo apt-get install -y libnotify-bin pulseaudio-utils
fi

echo "Configuração de notificações de bateria concluída!"
echo "Reinicie o Hyprland para aplicar as alterações."