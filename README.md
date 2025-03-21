# Configure My Distro

Script automatizado para configuração personalizada de uma distribuição Linux nova.

## Como usar

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/configure-my-distro.git
cd configure-my-distro

# Execute o script principal
./setup.sh
```

## Estrutura do Projeto

```
.
├── modules/              # Módulos individuais de configuração
│   ├── apps/            # Instalação de aplicativos
│   ├── system/          # Configurações do sistema
│   └── dev/             # Configurações de desenvolvimento
├── scripts/             # Scripts auxiliares
├── config/              # Arquivos de configuração
└── setup.sh            # Script principal de instalação
```

## Módulos Disponíveis

- **apps**: Instalação de aplicativos como Cursor, navegadores, etc.
- **system**: Configurações básicas do sistema
- **dev**: Configuração de ambiente de desenvolvimento

## Requisitos

- Ubuntu/Debian based distribution
- Bash shell
- Acesso sudo 