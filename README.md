# 🚀 Configure My Distro

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange.svg)](https://ubuntu.com/)

Uma solução elegante e modular para automatizar a configuração completa do seu ambiente Ubuntu, incluindo instalação de aplicativos, configurações do sistema e personalização do ambiente.

[Instalação](#-instalação) • [Uso](#-uso) • [Estrutura](#-estrutura) • [Contribuindo](#-contribuindo)

</div>

## 🌟 Características

- **Modular**: Organizado em módulos independentes para fácil manutenção e extensão
- **Idempotente**: Pode ser executado múltiplas vezes sem efeitos colaterais
- **Personalizável**: Fácil de adaptar às suas necessidades específicas
- **Robusto**: Tratamento de erros e verificações de segurança
- **Elegante**: Interface de usuário clara e informativa

## 🛠️ Módulos Disponíveis

### 📦 Aplicativos
- Google Chrome
- Visual Studio Code
- DBeaver (Gerenciador de Banco de Dados)
- Remmina (Cliente RDP/VNC)
- Insync (Cliente Google Drive)
- FortiClient VPN

### ⚙️ Sistema
- Git e SSH
- Hyprland (Compositor Wayland)
- Configurações de Touchpad
- Variáveis de Ambiente e Aliases

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone https://github.com/tridentinho/configure-my-distro.git
cd configure-my-distro
```

2. Torne os scripts executáveis:
```bash
chmod +x setup.sh
```

## 💻 Uso

### Instalação Completa
Para executar todas as configurações:
```bash
sudo ./setup.sh
```

### Módulos Individuais
Para executar apenas um módulo específico:

```bash
# Módulo de Aplicativos
sudo ./modules/apps/install.sh

# Módulo de Sistema
sudo ./modules/system/install.sh
```

### Scripts Individuais
Para executar um script específico:

```bash
# Exemplo: Instalar apenas o VSCode
sudo ./modules/apps/scripts/vscode.sh

# Exemplo: Configurar apenas o touchpad
sudo ./modules/system/scripts/touchpad.sh
```

### Modo Forçado
Para forçar a reinstalação de um componente:
```bash
sudo ./modules/apps/scripts/vscode.sh --force
```

## 📁 Estrutura

```
configure-my-distro/
├── modules/
│   ├── apps/
│   │   ├── install.sh
│   │   └── scripts/
│   │       ├── chrome.sh
│   │       ├── vscode.sh
│   │       └── ...
│   └── system/
│       ├── install.sh
│       └── scripts/
│           ├── git.sh
│           ├── touchpad.sh
│           └── ...
├── scripts/
│   └── common.sh
└── setup.sh
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, siga estas etapas:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- [Hyprland](https://github.com/hyprwm/Hyprland)
- [Visual Studio Code](https://code.visualstudio.com/)
- [DBeaver](https://dbeaver.io/)
- [Remmina](https://remmina.org/)
- [Insync](https://www.insynchq.com/)
- [FortiClient](https://www.fortinet.com/products/forticlient)

---

<div align="center">
Feito com ❤️ para a comunidade Linux
</div> 