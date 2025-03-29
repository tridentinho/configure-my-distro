#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_docker() {
    log "Instalando Docker Engine, CLI e Docker Compose..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Verifica se o Docker CLI já está instalado
    if command -v docker &> /dev/null && [ "$1" != "--force" ]; then
        log "Docker CLI já está instalado"
        log "Use --force para reinstalar"
    else
        # Se estiver em modo forçado, remove a instalação anterior do Docker CLI
        if [ "$1" == "--force" ]; then
            log "Modo forçado: removendo instalação anterior do Docker CLI..."
            apt-get remove -y docker-ce-cli
            apt-get autoremove -y
            apt-get clean
        fi

        # Atualiza os repositórios
        log "Atualizando repositórios..."
        apt-get update

        # Instala dependências necessárias
        log "Instalando dependências..."
        apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Adiciona a chave GPG oficial do Docker
        log "Adicionando chave GPG do Docker..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Configura o repositório do Docker
        log "Configurando repositório do Docker..."
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Atualiza os repositórios novamente
        apt-get update

        # Instala o Docker CLI
        log "Instalando Docker CLI..."
        apt-get install -y docker-ce-cli
    fi

    # Verifica se o Docker Compose já está instalado
    if command -v docker compose &> /dev/null && [ "$1" != "--force" ]; then
        log "Docker Compose já está instalado"
        log "Use --force para reinstalar"
    else
        # Se estiver em modo forçado, remove a instalação anterior do Docker Compose
        if [ "$1" == "--force" ]; then
            log "Modo forçado: removendo instalação anterior do Docker Compose..."
            apt-get remove -y docker-compose-plugin
            apt-get autoremove -y
            apt-get clean
        fi

        # Instala o Docker Compose
        log "Instalando Docker Compose..."
        apt-get install -y docker-compose-plugin
    fi

    # Instala o Docker CLI e Docker Compose
    log "Instalando Docker Engine, CLI e Docker Compose..."
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Adiciona o usuário atual ao grupo docker
    log "Adicionando usuário ao grupo docker..."
    usermod -aG docker $CURRENT_USER

    # Inicia e habilita o serviço do Docker
    log "Iniciando serviço do Docker..."
    systemctl enable --now docker

    # Verifica se a instalação foi bem sucedida
    if command -v docker &> /dev/null && command -v docker compose &> /dev/null && systemctl is-active --quiet docker; then
        log "Docker Engine, CLI e Docker Compose instalados com sucesso!"
        log "Para usar o Docker sem sudo, faça logout e login novamente"
        log "Para usar o Docker, execute: docker"
        log "Para usar o Docker Compose, execute: docker compose"
        return 0
    else
        error "Falha ao instalar Docker Engine, CLI ou Docker Compose"
        return 1
    fi
}

# Executa a instalação com os argumentos passados
install_docker "$1"