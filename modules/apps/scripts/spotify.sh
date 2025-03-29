#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_spotify() {
    log "Instalando Spotify..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Verifica se já está instalado e se não está em modo forçado
    if command -v spotify &> /dev/null && [ "$1" != "--force" ]; then
        log "Spotify já está instalado"
        log "Use --force para reinstalar"
        return 0
    fi

    # Se estiver em modo forçado, remove a instalação anterior
    if [ "$1" == "--force" ]; then
        log "Modo forçado: removendo instalação anterior..."
        apt-get remove -y spotify-client
        apt-get autoremove -y
        apt-get clean
        rm -rf "/home/$CURRENT_USER/.config/spotify"
        rm -rf "/home/$CURRENT_USER/.cache/spotify"
        
        # Remove arquivos antigos do repositório
        rm -f /etc/apt/sources.list.d/spotify.list
        rm -f /etc/apt/trusted.gpg.d/spotify.gpg
        rm -f /etc/apt/trusted.gpg.d/spotify-2.gpg
        rm -f /etc/apt/keyrings/spotify.gpg
    fi

    # Atualiza os repositórios
    log "Atualizando repositórios..."
    apt-get update

    # Instala dependências necessárias
    log "Instalando dependências..."
    apt-get install -y curl gnupg2

    # Cria o diretório keyrings se não existir
    mkdir -p /etc/apt/keyrings

    # Adiciona o repositório do Spotify com a chave GPG correta
    log "Adicionando repositório e chave GPG do Spotify..."
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/spotify.gpg
    
    # Configura o repositório
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list
    
    # Atualiza novamente os repositórios
    apt-get update

    # Instala o Spotify
    log "Instalando Spotify..."
    apt-get install -y spotify-client

    # Verifica se a instalação foi bem sucedida
    if command -v spotify &> /dev/null; then
        log "Spotify instalado com sucesso!"
        log "Para usar o Spotify, execute: spotify"
        return 0
    else
        error "Falha ao instalar o Spotify"
        return 1
    fi
}

# Executa a instalação com os argumentos passados
install_spotify "$1" 