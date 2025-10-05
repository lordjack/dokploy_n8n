#!/bin/bash

echo "🚀 Iniciando Dokploy no Render.com..."

# Configurar variáveis de ambiente padrão se não estiverem definidas
export DOKPLOY_PORT=${PORT:-3000}
export DOKPLOY_HOST=${DOKPLOY_HOST:-"0.0.0.0"}
export DOKPLOY_SECRET_KEY=${DOKPLOY_SECRET_KEY:-$(openssl rand -hex 32)}

echo "📋 Configurações:"
echo "  - Porta: $DOKPLOY_PORT"
echo "  - Host: $DOKPLOY_HOST"

# Verificar se estamos em um ambiente privilegiado para Docker
echo "🔍 Verificando ambiente Docker..."
if [ ! -S /var/run/docker.sock ]; then
    echo "🐳 Iniciando Docker daemon..."
    # Tentar iniciar dockerd em background
    sudo dockerd --host=unix:///var/run/docker.sock --iptables=false --bridge=none &
    DOCKER_PID=$!
    
    # Aguardar socket estar disponível
    for i in {1..30}; do
        if [ -S /var/run/docker.sock ]; then
            echo "✅ Docker socket disponível!"
            break
        fi
        echo "⏳ Aguardando Docker socket... ($i/30)"
        sleep 2
    done
    
    if [ ! -S /var/run/docker.sock ]; then
        echo "❌ Timeout aguardando Docker socket!"
        echo "ℹ️  Continuando sem Docker daemon local..."
    fi
else
    echo "✅ Docker socket já disponível!"
fi

# Instalar Dokploy se não estiver instalado
if ! command -v dokploy &> /dev/null; then
    echo "📦 Dokploy não encontrado, instalando..."
    /usr/local/bin/install-dokploy.sh
    
    # Se a instalação falhar, tentar modo standalone
    if ! command -v dokploy &> /dev/null; then
        echo "⚠️  Instalação padrão falhou, tentando modo standalone..."
        exec /usr/local/bin/start-standalone.sh
    fi
fi

# Verificar se Docker está funcionando
echo "🔍 Testando Docker..."
DOCKER_AVAILABLE=false
if docker info > /dev/null 2>&1; then
    DOCKER_AVAILABLE=true
    echo "✅ Docker está funcionando!"
else
    echo "⚠️  Docker não está disponível - rodando em modo standalone"
fi

# Configurar Dokploy
echo "⚙️ Configurando Dokploy..."

# Criar arquivo de configuração
mkdir -p ~/.dokploy
if [ "$DOCKER_AVAILABLE" = true ]; then
    cat << EOF > ~/.dokploy/config.json
{
  "port": $DOKPLOY_PORT,
  "host": "$DOKPLOY_HOST",
  "secretKey": "$DOKPLOY_SECRET_KEY",
  "docker": {
    "host": "unix:///var/run/docker.sock"
  }
}
EOF
else
    cat << EOF > ~/.dokploy/config.json
{
  "port": $DOKPLOY_PORT,
  "host": "$DOKPLOY_HOST",
  "secretKey": "$DOKPLOY_SECRET_KEY",
  "standalone": true
}
EOF
fi

echo "🎯 Iniciando Dokploy..."

# Iniciar Dokploy com as configurações apropriadas
if [ "$DOCKER_AVAILABLE" = true ]; then
    echo "🐳 Iniciando com suporte Docker..."
    exec dokploy start --port $DOKPLOY_PORT --host $DOKPLOY_HOST
else
    echo "📦 Iniciando em modo standalone..."
    exec dokploy start --port $DOKPLOY_PORT --host $DOKPLOY_HOST --standalone
fi