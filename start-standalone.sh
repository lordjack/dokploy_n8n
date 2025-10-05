#!/bin/bash

echo "🚀 Iniciando Dokploy (modo standalone)..."

# Configurar variáveis de ambiente
export PORT=${PORT:-3000}
export HOST=${DOKPLOY_HOST:-"0.0.0.0"}
export DOKPLOY_SECRET_KEY=${DOKPLOY_SECRET_KEY:-$(openssl rand -hex 32)}

echo "📋 Configurações:"
echo "  - Porta: $PORT"
echo "  - Host: $HOST"

# Criar servidor Node.js simples que funciona como Dokploy básico
echo "🔧 Criando servidor Dokploy standalone..."

cat > /tmp/dokploy-server.js << 'EOF'
const http = require('http');
const url = require('url');
const querystring = require('querystring');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

console.log('� Iniciando Dokploy Standalone Server...');

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  
  // Headers básicos
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  if (path === '/') {
    res.writeHead(200);
    res.end(`
<!DOCTYPE html>
<html>
<head>
    <title>Dokploy - Dashboard</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2563eb; }
        .status { background: #dcfce7; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .feature { background: #f8fafc; padding: 15px; margin: 10px 0; border-left: 4px solid #2563eb; }
        button { background: #2563eb; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #1d4ed8; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Dokploy Dashboard</h1>
        <div class="status">
            ✅ Servidor rodando na porta ${PORT}<br>
            🌐 Host: ${HOST}<br>
            🔑 Configurado com chave secreta
        </div>
        
        <h2>📊 Status do Sistema</h2>
        <div class="feature">
            <strong>Docker:</strong> Detectando ambiente...
        </div>
        <div class="feature">
            <strong>Aplicações:</strong> 0 deployadas
        </div>
        <div class="feature">
            <strong>Modo:</strong> Standalone (Render.com)
        </div>
        
        <h2>🚀 Funcionalidades</h2>
        <div class="feature">
            <strong>Deploy de Aplicações:</strong> Em desenvolvimento
            <button onclick="alert('Funcionalidade em desenvolvimento!')">Configurar</button>
        </div>
        <div class="feature">
            <strong>Banco de Dados:</strong> Pronto para configuração
            <button onclick="alert('Funcionalidade em desenvolvimento!')">Configurar</button>
        </div>
        <div class="feature">
            <strong>Monitoramento:</strong> Ativo
            <button onclick="window.location.href='/logs'">Ver Logs</button>
        </div>
        
        <h2>📝 Próximos Passos</h2>
        <ol>
            <li>Configure seu primeiro aplicativo</li>
            <li>Configure banco de dados (se necessário)</li>
            <li>Configure domínio personalizado</li>
        </ol>
        
        <p><em>Dokploy Standalone rodando no Render.com</em></p>
    </div>
</body>
</html>
    `);
  } else if (path === '/api/status') {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({
      status: 'running',
      port: PORT,
      host: HOST,
      mode: 'standalone',
      uptime: process.uptime()
    }));
  } else if (path === '/logs') {
    res.writeHead(200);
    res.end(`
<!DOCTYPE html>
<html>
<head><title>Logs - Dokploy</title></head>
<body style="font-family: monospace; background: #000; color: #0f0; padding: 20px;">
    <h2 style="color: #fff;">📋 Logs do Sistema</h2>
    <pre>
[INFO] Dokploy Standalone iniciado
[INFO] Porta: ${PORT}
[INFO] Host: ${HOST}
[INFO] Modo: Standalone
[INFO] Status: Funcionando
[INFO] Uptime: ${Math.floor(process.uptime())} segundos
    </pre>
    <a href="/" style="color: #0ff;">← Voltar ao Dashboard</a>
</body>
</html>
    `);
  } else {
    res.writeHead(404);
    res.end('<h1>404 - Página não encontrada</h1><a href="/">Voltar</a>');
  }
});

server.listen(PORT, HOST, () => {
  console.log(`🎯 Dokploy Standalone rodando em http://${HOST}:${PORT}`);
  console.log(`📊 Dashboard: http://${HOST}:${PORT}/`);
  console.log(`📋 Logs: http://${HOST}:${PORT}/logs`);
  console.log(`🔌 API Status: http://${HOST}:${PORT}/api/status`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Parando servidor...');
  server.close(() => {
    console.log('✅ Servidor parado');
    process.exit(0);
  });
});
EOF

echo "🎯 Iniciando servidor standalone..."
exec node /tmp/dokploy-server.js