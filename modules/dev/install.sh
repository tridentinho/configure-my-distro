#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/scripts/common.sh"

# Diretório dos scripts de desenvolvimento
DEV_SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")/scripts"

log "Iniciando instalação de ferramentas de desenvolvimento..."

# Lista de ferramentas de desenvolvimento
dev_tools=(
    "node_dev"  # Instala ferramentas Node.js (NVM, Yarn, NestJS, Next.js)
    # Adicione mais ferramentas de desenvolvimento aqui
)

# Função para instalar uma ferramenta específica
install_dev_tool() {
    local tool_script="$DEV_SCRIPTS_DIR/$1.sh"
    if [ -f "$tool_script" ]; then
        log "Instalando ferramenta: $1..."
        if bash "$tool_script"; then
            log "Ferramenta $1 instalada com sucesso!"
        else
            error "Falha ao instalar ferramenta $1"
        fi
    else
        error "Script de instalação não encontrado para $1"
    fi
}

# Instala cada ferramenta
for tool in "${dev_tools[@]}"; do
    install_dev_tool "$tool"
done

log "Instalação de ferramentas de desenvolvimento concluída!" 