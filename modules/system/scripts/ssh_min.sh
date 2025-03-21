#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

configure_ssh() {
    log "Configurando permissões das chaves SSH..."

    # Configura para o usuário atual (não root)
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    local USER_HOME="/home/$CURRENT_USER"
    local SSH_DIR="$USER_HOME/.ssh"

    # Instruções para o usuário
    echo -e "\nAntes de continuar, por favor:"
    echo "1. Transfira suas chaves SSH privadas (id_rsa, id_ed25519, etc) para $SSH_DIR"
    echo "2. Transfira suas chaves públicas correspondentes (*.pub)"
    echo "3. Se tiver, transfira também seus arquivos known_hosts e config"
    echo "4. Certifique-se de fazer backup das suas chaves em local seguro"
    echo -e "\nPressione ENTER quando estiver pronto para continuar..."
    read

    # Verifica se o diretório .ssh existe
    if [ ! -d "$SSH_DIR" ]; then
        log "Diretório .ssh não encontrado"
        return 1
    fi

    log "Ajustando permissões dos arquivos SSH..."

    # Ajusta as permissões do diretório .ssh
    chmod 700 "$SSH_DIR"
    chown $CURRENT_USER:$CURRENT_USER "$SSH_DIR"

    # Ajusta as permissões de todos os arquivos no diretório .ssh
    find "$SSH_DIR" -type f | while read -r file; do
        # Chaves privadas (arquivos sem extensão .pub)
        if [[ "$file" != *.pub ]]; then
            chmod 600 "$file"
        # Chaves públicas e outros arquivos
        else
            chmod 644 "$file"
        fi
        # Define o owner para todos os arquivos
        chown $CURRENT_USER:$CURRENT_USER "$file"
    done

    log "Permissões das chaves SSH ajustadas com sucesso!"
    log "Arquivos configurados:"
    ls -la "$SSH_DIR"
}

# Executa a configuração
configure_ssh