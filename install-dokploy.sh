#!/bin/bash

# Script para instalar Dokploy
# Este script será executado durante a inicialização do container

echo "🚀 Iniciando instalação do Dokploy..."

# Verificar se Docker está funcionando
echo "🐳 Verificando Docker..."
if ! docker --version > /dev/null 2>&1; then
    echo "❌ Docker não está disponível!"
    exit 1
fi

# Iniciar o daemon do Docker se não estiver rodando
sudo service docker start

# Baixar e instalar Dokploy
echo "📦 Baixando Dokploy..."
curl -sSL https://dokploy.com/install.sh | sh

# Verificar se a instalação foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "✅ Dokploy instalado com sucesso!"
else
    echo "❌ Falha na instalação do Dokploy!"
    exit 1
fi

echo "🎉 Instalação do Dokploy concluída!"