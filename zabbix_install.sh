#!/bin/bash
##############################################################################
# 
# Script de instalação Zabbix
# Data: 19/07/2024
# Author: Paulo Janoti - TIC-Cloud
#
# Sistema: Debian, Ubuntu, RHEL, CentOS, Amazon Linux
# Arquitetura: x86_64, aarch64
#
##############################################################################

# Função para verificar o sucesso do comando
check_command_success() {
    if [ $? -ne 0 ]; then
        echo "#####################################################"
        echo "#####################################################"
        echo ""
        echo "$1 failed. Exiting."
        exit 1
    fi
}

# Variáveis
ZABBIX_SERVER=zabbix.matera.com
OS=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
OS_VERSION=$(grep '^VERSION_ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
ARCH=$(uname -m)

echo "#####################################################"
echo "#####################################################"
echo ""
echo "MATERA TIC CLOUD"
echo ""
echo "Zabbix Agent 2 Installation"
echo ""
echo "#####################################################"
echo "#####################################################"

# Verificar arquitetura
if [[ "$ARCH" == "x86_64" ]]; then
    echo "#####################################################"
    echo "#####################################################"
    echo ""
    echo "x86_64 Architecture."
    echo ""
    echo "#####################################################"
    echo "#####################################################"
    ARCH_SUFFIX="x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    echo "#####################################################"
    echo "#####################################################"
    echo ""
    echo "aarch64 Architecture."
    echo ""
    echo "#####################################################"
    echo "#####################################################"
    ARCH_SUFFIX="aarch64"
else
    echo "#####################################################"
    echo "#####################################################"
    echo ""
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Verificar sistema operacional
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    echo "#####################################################"
    echo "#####################################################"
    echo ""
    echo "Detected Debian/Ubuntu system."
    echo ""
    echo "#####################################################"
    echo "#####################################################"
    


    # Instalação do repositório Zabbix
    if [[ "$ARCH" == "x86_64" ]]; then
        apt update
        apt install -y wget
        wget https://repo.zabbix.com/zabbix/6.5/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu${OS_VERSION}_all.deb
        dpkg -i zabbix-release_latest+ubuntu${OS_VERSION}_all.deb
        check_command_success "Zabbix_Repo-install"

        # Instalação do Zabbix Agent 2
        apt update
        apt install zabbix-agent2 -y
        check_command_success "zabbix-install"

    elif [[ "$ARCH" == "aarch64" ]]; then    
        apt update
        apt install -y wget
        wget https://repo.zabbix.com/zabbix/6.4/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu24.04_all.deb
        dpkg -i zabbix-release_latest+ubuntu${OS_VERSION}_all.deb
        check_command_success "Zabbix_Repo-install"

        # Instalação do Zabbix Agent 2
        apt update
        apt install zabbix-agent2 -y
        check_command_success "zabbix-install"
    fi    
elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "amzn" ]]; then

    echo "#####################################################"
    echo "#####################################################"
    echo ""
    echo "Detected RHEL/CentOS/Amazon Linux system."
    echo ""
    echo "#####################################################"
    echo "#####################################################"

    # Instalação do repositório Zabbix
    if [[ "$ARCH" == "x86_64" ]]; then
        rpm -Uvh https://repo.zabbix.com/zabbix/7.0/alma/9/${ARCH_SUFFIX}/zabbix-release-7.0-4.el9.noarch.rpm    
        check_command_success "Zabbix_Repo-install"

        # Instalação do Zabbix Agent 2
        yum install zabbix-agent2 -y
        check_command_success "zabbix-install"
    elif [[ "$ARCH" == "aarch64" ]]; then
        rpm -Uvh https://repo.zabbix.com/zabbix/7.0/alma/9/aarch64/zabbix-agent2-7.0.2-release1.el9.aarch64.rpm
        check_command_success "Zabbix_Repo-install"

        # Instalação do Zabbix Agent 2
        yum install zabbix-agent2 -y
        check_command_success "zabbix-install"
    fi

else
    echo "#####################################################"
    echo "#####################################################"
    echo ""
    echo "Unsupported OS: $OS"
    exit 1
fi

# Edição do arquivo de configuração /etc/zabbix/zabbix_agent2.conf
sed -i 's/^Server=127.0.0.1$/Server='${ZABBIX_SERVER}'/' /etc/zabbix/zabbix_agent2.conf
sed -i 's/^ServerActive=127.0.0.1$/ServerActive='${ZABBIX_SERVER}':10051/' /etc/zabbix/zabbix_agent2.conf
sed -i 's/^Hostname=Zabbix server$/Hostname='${HOSTNAME}'/' /etc/zabbix/zabbix_agent2.conf
check_command_success "zabbix-sed"

# Adicionar a linha AllowKey=system.run[*]
echo "AllowKey=system.run[*]" >> /etc/zabbix/zabbix_agent2.conf
check_command_success "AllowKey"

# Iniciar o serviço Zabbix Agent 2
systemctl start zabbix-agent2
check_command_success "zabbix-start"

# Habilitar o serviço Zabbix Agent 2 para iniciar na inicialização do sistema
systemctl enable zabbix-agent2
check_command_success "zabbix-enable"

echo "#####################################################"
echo "#####################################################"
echo ""
echo "Zabbix Agent 2 installation completed successfully."
echo ""
echo "#####################################################"
echo "#####################################################"
