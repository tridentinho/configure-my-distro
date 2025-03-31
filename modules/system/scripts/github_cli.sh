#!/bin/bash

# Importa funções comuns
source "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")/scripts/common.sh"

install_github_cli() {
    log "Instalando GitHub CLI (gh)..."

    # Verifica se está sendo executado com sudo
    local CURRENT_USER=$SUDO_USER
    if [ -z "$CURRENT_USER" ]; then
        error "Este script deve ser executado com sudo"
        return 1
    fi

    # Obtém o diretório home do usuário atual
    local USER_HOME=$(eval echo ~$CURRENT_USER)

    # Verifica se já está instalado e se não está em modo forçado
    if command -v gh &>/dev/null && [ "$1" != "--force" ]; then
        log "GitHub CLI já está instalado"
        gh --version
        log "Use --force para reinstalar"
        return 0
    fi

    # Detecta o sistema operacional
    local OS_TYPE=$(uname -s)
    
    case "$OS_TYPE" in
        Linux)
            install_on_linux
            ;;
        Darwin)
            install_on_macos
            ;;
        *)
            error "Sistema operacional não suportado: $OS_TYPE"
            log "Por favor, consulte https://github.com/cli/cli#installation para instruções manuais."
            return 1
            ;;
    esac

    # Verifica se a instalação foi bem-sucedida
    if ! command -v gh &>/dev/null; then
        error "Falha ao instalar GitHub CLI"
        return 1
    fi

    # Configuração do GitHub CLI
    log "GitHub CLI instalado com sucesso!"
    log "Versão instalada:"
    gh --version
    
    # Pergunta se o usuário deseja fazer login
    log "Deseja configurar a autenticação com o GitHub? (s/n)"
    read -r CONF_AUTH
    
    if [[ "$CONF_AUTH" =~ ^[Ss]$ ]]; then
        log "Iniciando processo de autenticação..."
        sudo -u $CURRENT_USER bash -c "gh auth login"
    else
        log "Você pode fazer login posteriormente usando o comando: gh auth login"
    fi
    
    log "Para mais informações sobre como usar o GitHub CLI, execute: gh --help"
    return 0
}

install_on_linux() {
    # Detecta a distribuição Linux
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        error "Não foi possível detectar a distribuição Linux"
        return 1
    fi

    log "Distribuição Linux detectada: $DISTRO"
    
    # Apresenta opções de instalação
    log "Selecione o método de instalação para o GitHub CLI:"
    log "1) Repositório oficial (Debian/Ubuntu/Fedora/RHEL)"
    log "2) Homebrew"
    log "3) Conda"
    log "4) Spack"
    log "5) Binário pré-compilado"
    log "0) Cancelar"
    
    read -r OPTION
    
    case $OPTION in
        1)
            install_from_repo
            ;;
        2)
            install_with_homebrew
            ;;
        3)
            install_with_conda
            ;;
        4)
            install_with_spack
            ;;
        5)
            install_from_binary
            ;;
        0)
            log "Instalação cancelada"
            return 1
            ;;
        *)
            error "Opção inválida"
            return 1
            ;;
    esac
}

install_from_repo() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
    
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            log "Instalando para Debian/Ubuntu..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y
            ;;
        fedora|rhel|centos|rocky|alma)
            log "Instalando para Fedora/RHEL/CentOS..."
            sudo dnf install -y 'dnf-command(config-manager)'
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install -y gh
            ;;
        *)
            error "Distribuição não suportada para instalação via repositório: $DISTRO"
            log "Tente outro método de instalação"
            return 1
            ;;
    esac
}

install_with_homebrew() {
    if ! command -v brew &>/dev/null; then
        log "Homebrew não está instalado. Deseja instalar o Homebrew? (s/n)"
        read -r INSTALL_BREW
        
        if [[ "$INSTALL_BREW" =~ ^[Ss]$ ]]; then
            log "Instalando Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            error "Homebrew é necessário para este método de instalação"
            return 1
        fi
    fi
    
    log "Instalando GitHub CLI via Homebrew..."
    sudo -u $CURRENT_USER bash -c "brew install gh"
}

install_with_conda() {
    if ! command -v conda &>/dev/null; then
        error "Conda não está instalado"
        log "Por favor, instale o Conda primeiro e tente novamente"
        return 1
    fi
    
    log "Instalando GitHub CLI via Conda..."
    sudo -u $CURRENT_USER bash -c "conda install gh --channel conda-forge -y"
}

install_with_spack() {
    if ! command -v spack &>/dev/null; then
        error "Spack não está instalado"
        log "Por favor, instale o Spack primeiro e tente novamente"
        return 1
    fi
    
    log "Instalando GitHub CLI via Spack..."
    sudo -u $CURRENT_USER bash -c "spack install gh"
}

install_from_binary() {
    local ARCH=$(uname -m)
    local VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep tag_name | cut -d '"' -f 4)
    local FILENAME="gh_${VERSION#v}_linux_$ARCH.tar.gz"
    local URL="https://github.com/cli/cli/releases/download/${VERSION}/${FILENAME}"
    
    log "Baixando GitHub CLI $VERSION para $ARCH..."
    
    cd /tmp
    curl -LO "$URL"
    
    log "Extraindo arquivos..."
    tar xzf "$FILENAME"
    
    log "Instalando GitHub CLI..."
    sudo cp -r "gh_${VERSION#v}_linux_$ARCH/bin/gh" /usr/local/bin/
    sudo cp -r "gh_${VERSION#v}_linux_$ARCH/share/man/man1/" /usr/local/share/man/
    
    log "Limpando arquivos temporários..."
    rm -rf "gh_${VERSION#v}_linux_$ARCH" "$FILENAME"
}

install_on_macos() {
    log "Selecione o método de instalação para macOS:"
    log "1) Homebrew (recomendado)"
    log "2) MacPorts"
    log "3) Conda"
    log "4) Spack"
    log "5) Webi"
    log "6) Binário pré-compilado"
    log "0) Cancelar"
    
    read -r OPTION
    
    case $OPTION in
        1)
            install_macos_homebrew
            ;;
        2)
            install_macos_macports
            ;;
        3)
            install_macos_conda
            ;;
        4)
            install_macos_spack
            ;;
        5)
            install_macos_webi
            ;;
        6)
            install_macos_binary
            ;;
        0)
            log "Instalação cancelada"
            return 1
            ;;
        *)
            error "Opção inválida"
            return 1
            ;;
    esac
}

install_macos_homebrew() {
    if ! command -v brew &>/dev/null; then
        log "Homebrew não está instalado. Deseja instalar o Homebrew? (s/n)"
        read -r INSTALL_BREW
        
        if [[ "$INSTALL_BREW" =~ ^[Ss]$ ]]; then
            log "Instalando Homebrew..."
            sudo -u $CURRENT_USER bash -c "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        else
            error "Homebrew é necessário para este método de instalação"
            return 1
        fi
    fi
    
    log "Instalando GitHub CLI via Homebrew..."
    sudo -u $CURRENT_USER bash -c "brew install gh"
}

install_macos_macports() {
    if ! command -v port &>/dev/null; then
        error "MacPorts não está instalado"
        log "Por favor, instale o MacPorts primeiro e tente novamente"
        return 1
    fi
    
    log "Instalando GitHub CLI via MacPorts..."
    sudo port install gh
}

install_macos_conda() {
    if ! command -v conda &>/dev/null; then
        error "Conda não está instalado"
        log "Por favor, instale o Conda primeiro e tente novamente"
        return 1
    fi
    
    log "Instalando GitHub CLI via Conda..."
    sudo -u $CURRENT_USER bash -c "conda install gh --channel conda-forge -y"
}

install_macos_spack() {
    if ! command -v spack &>/dev/null; then
        error "Spack não está instalado"
        log "Por favor, instale o Spack primeiro e tente novamente"
        return 1
    fi
    
    log "Instalando GitHub CLI via Spack..."
    sudo -u $CURRENT_USER bash -c "spack install gh"
}

install_macos_webi() {
    log "Instalando GitHub CLI via Webi..."
    sudo -u $CURRENT_USER bash -c "curl -sS https://webi.sh/gh | sh"
}

install_macos_binary() {
    local ARCH=$(uname -m)
    local VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep tag_name | cut -d '"' -f 4)
    local FILENAME="gh_${VERSION#v}_macOS_$ARCH.zip"
    local URL="https://github.com/cli/cli/releases/download/${VERSION}/${FILENAME}"
    
    log "Baixando GitHub CLI $VERSION para macOS $ARCH..."
    
    cd /tmp
    curl -LO "$URL"
    
    log "Extraindo arquivos..."
    unzip -q "$FILENAME"
    
    log "Instalando GitHub CLI..."
    sudo cp -r "gh_${VERSION#v}_macOS_$ARCH/bin/gh" /usr/local/bin/
    
    log "Limpando arquivos temporários..."
    rm -rf "gh_${VERSION#v}_macOS_$ARCH" "$FILENAME"
}

# Executa a instalação com os argumentos passados
install_github_cli "$1" 