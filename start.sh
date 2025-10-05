#!/bin/bash

echo "🚀 Iniciando Dokploy no Render.com..."

# Configurar variáveis de ambiente padrão se não estiverem definidas
export DOKPLOY_PORT=${PORT:-3000}
export DOKPLOY_HOST=${DOKPLOY_HOST:-"0.0.0.0"}
export DOKPLOY_SECRET_KEY=${DOKPLOY_SECRET_KEY:-$(openssl rand -hex 32)}

echo "📋 Configurações:"
echo "  - Porta: $DOKPLOY_PORT"
echo "  - Host: $DOKPLOY_HOST"

# Verificar se estamos rodando como root ou temos sudo
if [ "$EUID" -eq 0 ]; then
    echo "🔑 Rodando como root"
    SUDO_CMD=""
else
    echo "👤 Rodando como usuário - usando sudo quando necessário"
    SUDO_CMD="sudo"
fi

# Verificar se estamos em um ambiente privilegiado para Docker
echo "🔍 Verificando ambiente Docker..."
DOCKER_AVAILABLE=false

# Tentar iniciar dockerd se não estiver rodando
if [ ! -S /var/run/docker.sock ]; then
    echo "🐳 Tentando iniciar Docker daemon..."
    $SUDO_CMD dockerd --host=unix:///var/run/docker.sock --iptables=false --bridge=none &
    DOCKER_PID=$!
    
    # Aguardar um pouco para o daemon iniciar
    sleep 5
    
    # Verificar se funcionou
    if docker info > /dev/null 2>&1; then
        DOCKER_AVAILABLE=true
        echo "✅ Docker daemon iniciado!"
    else
        echo "⚠️  Docker daemon não pôde ser iniciado"
        # Matar processo se ainda estiver rodando
        [ ! -z "$DOCKER_PID" ] && kill $DOCKER_PID 2>/dev/null
    fi
else
    # Socket já existe, verificar se funciona
    if docker info > /dev/null 2>&1; then
        DOCKER_AVAILABLE=true
        echo "✅ Docker já está funcionando!"
    else
        echo "⚠️  Docker socket existe mas não funciona"
    fi
fi

# Se Docker não está disponível, usar modo standalone
if [ "$DOCKER_AVAILABLE" = false ]; then
    echo "🔄 Docker não disponível, iniciando em modo standalone..."
    exec /usr/local/bin/start-standalone.sh
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