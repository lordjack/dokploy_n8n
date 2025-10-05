#!/bin/bash

# Script para instalar Dokploy
# Este script será executado durante a inicialização do container

echo "🚀 Iniciando instalação do Dokploy..."

# Verificar se já está instalado
if command -v dokploy &> /dev/null; then
    echo "✅ Dokploy já está instalado!"
    dokploy --version
    exit 0
fi

# Baixar e instalar Dokploy
echo "📦 Baixando Dokploy..."

# Usar método alternativo se o script padrão falhar
if ! curl -sSL https://dokploy.com/install.sh | sh; then
    echo "⚠️  Script padrão falhou, tentando instalação manual..."
    
    # Instalação manual via npm (fallback)
    echo "📦 Instalando via npm..."
    sudo npm install -g dokploy@latest
    
    if [ $? -eq 0 ]; then
        echo "✅ Dokploy instalado via npm!"
    else
        echo "❌ Falha na instalação do Dokploy!"
        exit 1
    fi
else
    echo "✅ Dokploy instalado com sucesso!"
fi

echo "🎉 Instalação do Dokploy concluída!"