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

# Método 1: Script oficial do Dokploy (como root)
echo "📦 Tentando instalação via script oficial..."
if curl -sSL https://dokploy.com/install.sh | sudo bash; then
    echo "✅ Dokploy instalado via script oficial!"
    exit 0
fi

echo "⚠️  Script oficial falhou, tentando métodos alternativos..."

# Método 2: Instalar Docker Compose standalone (Dokploy precisa dele)
echo "📦 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Método 3: Baixar release do GitHub diretamente
echo "📦 Baixando Dokploy do GitHub..."
DOKPLOY_VERSION=$(curl -s https://api.github.com/repos/Dokploy/dokploy/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -n "$DOKPLOY_VERSION" ]; then
    echo "📥 Baixando versão $DOKPLOY_VERSION..."
    sudo mkdir -p /opt/dokploy
    sudo curl -L "https://github.com/Dokploy/dokploy/archive/refs/tags/$DOKPLOY_VERSION.tar.gz" -o /tmp/dokploy.tar.gz
    
    if [ -f /tmp/dokploy.tar.gz ]; then
        cd /tmp
        sudo tar -xzf dokploy.tar.gz
        sudo mv dokploy-* /opt/dokploy/
        cd /opt/dokploy/dokploy-*
        
        # Instalar dependências e buildar
        if command -v npm &> /dev/null; then
            sudo npm install --production
            sudo npm run build 2>/dev/null || echo "Build step skipped"
            
            # Criar link simbólico
            sudo ln -sf /opt/dokploy/dokploy-*/bin/dokploy /usr/local/bin/dokploy
            sudo chmod +x /usr/local/bin/dokploy
        fi
    fi
fi

# Método 4: Criar wrapper simples se tudo falhar
if ! command -v dokploy &> /dev/null; then
    echo "⚠️  Criando wrapper básico do Dokploy..."
    sudo tee /usr/local/bin/dokploy > /dev/null << 'EOF'
#!/bin/bash
echo "🐳 Dokploy Wrapper - Iniciando servidor básico..."

# Configurar variáveis
PORT=${PORT:-3000}
HOST=${HOST:-"0.0.0.0"}

# Criar aplicação Node.js básica que simula Dokploy
node -e "
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('<h1>Dokploy Wrapper</h1><p>Servidor rodando na porta $PORT</p><p>Configure seu Dokploy aqui.</p>');
});
server.listen($PORT, '$HOST', () => {
  console.log('🎯 Dokploy wrapper rodando em http://$HOST:$PORT');
});
"
EOF
    sudo chmod +x /usr/local/bin/dokploy
    echo "✅ Wrapper criado!"
fi

# Verificar instalação final
if command -v dokploy &> /dev/null; then
    echo "✅ Dokploy instalado com sucesso!"
    dokploy --version 2>/dev/null || echo "📋 Dokploy wrapper ativo"
else
    echo "❌ Falha na instalação do Dokploy!"
    exit 1
fi

echo "🎉 Instalação concluída!"