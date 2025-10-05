#!/bin/bash

echo "🚀 Iniciando Dokploy (modo standalone)..."

# Configurar variáveis de ambiente
export PORT=${PORT:-3000}
export HOST=${DOKPLOY_HOST:-"0.0.0.0"}
export DOKPLOY_SECRET_KEY=${DOKPLOY_SECRET_KEY:-$(openssl rand -hex 32)}

echo "📋 Configurações:"
echo "  - Porta: $PORT"
echo "  - Host: $HOST"

# Verificar se Dokploy está instalado
if ! command -v dokploy &> /dev/null; then
    echo "📦 Instalando Dokploy..."
    
    # Tentar instalação via npm
    if command -v npm &> /dev/null; then
        npm install -g @dokploy/dokploy@latest || {
            echo "⚠️  Tentando instalação alternativa..."
            # Instalação manual se npm falhar
            git clone https://github.com/Dokploy/dokploy.git /tmp/dokploy || {
                echo "❌ Falha ao clonar repositório"
                exit 1
            }
            cd /tmp/dokploy
            npm install && npm run build && npm link
        }
    else
        echo "❌ npm não encontrado!"
        exit 1
    fi
fi

# Verificar instalação
if command -v dokploy &> /dev/null; then
    echo "✅ Dokploy encontrado!"
    dokploy --version
else
    echo "❌ Dokploy não foi instalado corretamente!"
    exit 1
fi

# Criar configuração básica
mkdir -p ~/.dokploy
cat > ~/.dokploy/config.json << EOF
{
  "port": $PORT,
  "host": "$HOST",
  "secretKey": "$DOKPLOY_SECRET_KEY",
  "database": {
    "type": "sqlite",
    "path": "~/.dokploy/database.sqlite"
  }
}
EOF

echo "🎯 Iniciando Dokploy..."

# Iniciar Dokploy
exec dokploy start --port $PORT --host $HOST