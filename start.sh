#!/bin/bash

echo "🚀 Iniciando Dokploy no Render.com..."

# Configurar variáveis de ambiente padrão se não estiverem definidas
export DOKPLOY_PORT=${PORT:-3000}
export DOKPLOY_HOST=${DOKPLOY_HOST:-"0.0.0.0"}
export DOKPLOY_SECRET_KEY=${DOKPLOY_SECRET_KEY:-$(openssl rand -hex 32)}

echo "📋 Configurações:"
echo "  - Porta: $DOKPLOY_PORT"
echo "  - Host: $DOKPLOY_HOST"

# Iniciar Docker daemon
echo "🐳 Iniciando Docker daemon..."
sudo dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2376 &
sleep 10

# Verificar se Docker está funcionando
echo "🔍 Verificando Docker..."
if ! docker version > /dev/null 2>&1; then
    echo "❌ Docker daemon não está funcionando!"
    exit 1
fi

# Instalar Dokploy se não estiver instalado
if ! command -v dokploy &> /dev/null; then
    echo "📦 Dokploy não encontrado, instalando..."
    /usr/local/bin/install-dokploy.sh
fi

# Configurar Dokploy
echo "⚙️ Configurando Dokploy..."

# Criar arquivo de configuração se não existir
if [ ! -f /etc/dokploy/dokploy.conf ]; then
    sudo mkdir -p /etc/dokploy
    cat << EOF | sudo tee /etc/dokploy/dokploy.conf
PORT=$DOKPLOY_PORT
HOST=$DOKPLOY_HOST
SECRET_KEY=$DOKPLOY_SECRET_KEY
DOCKER_HOST=unix:///var/run/docker.sock
EOF
fi

# Aguardar Docker estar completamente pronto
echo "⏳ Aguardando Docker estar pronto..."
timeout=60
while [ $timeout -gt 0 ]; do
    if docker info > /dev/null 2>&1; then
        echo "✅ Docker está pronto!"
        break
    fi
    echo "⏳ Aguardando Docker... ($timeout segundos restantes)"
    sleep 5
    timeout=$((timeout - 5))
done

if [ $timeout -le 0 ]; then
    echo "❌ Timeout aguardando Docker ficar pronto!"
    exit 1
fi

# Iniciar Dokploy
echo "🎯 Iniciando Dokploy..."
exec dokploy start --port $DOKPLOY_PORT --host $DOKPLOY_HOST