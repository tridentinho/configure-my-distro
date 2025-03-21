#!/bin/bash

# Importa funções comuns
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common.sh"

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    error "Por favor, execute este script como root (usando sudo)"
    exit 1
fi

# Diretório base do script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Torna todos os scripts .sh executáveis
log "Tornando scripts executáveis..."
find "$BASE_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Cria o diretório tmp se não existir
mkdir -p "$BASE_DIR/tmp"

# Função para executar módulos
run_module() {
    local module_path="$BASE_DIR/modules/$1/install.sh"
    if [ -f "$module_path" ]; then
        log "Executando módulo: $1"
        bash "$module_path"
    else
        error "Módulo $1 não encontrado"
        return 1
    fi
}

# Atualiza o sistema
log "Atualizando o sistema..."
# Verifica a última atualização do sistema
LAST_UPDATE_FILE="$BASE_DIR/tmp/update-success-stamp"
CURRENT_TIME=$(date +%s)
LAST_UPDATE_TIME=0

if [ -f "$LAST_UPDATE_FILE" ]; then
    LAST_UPDATE_TIME=$(stat -c %Y "$LAST_UPDATE_FILE")
fi

# Se a última atualização foi há mais de 24 horas (86400 segundos)
if [ $((CURRENT_TIME - LAST_UPDATE_TIME)) -gt 86400 ]; then
    log "Última atualização foi há mais de 24 horas. Atualizando sistema..."
    apt update
    apt upgrade -y
    # Cria arquivo de controle após atualização bem sucedida
    touch "$LAST_UPDATE_FILE"
else
    log "Sistema já foi atualizado recentemente. Pulando atualização."
fi

# Executa módulos na ordem correta
modules=(
    "system"
    "apps"
    "dev"
)

for module in "${modules[@]}"; do
    run_module "$module"
done

log "Configuração concluída com sucesso!"