# Deploy do Dokploy no Render.com

Este repositório está configurado para fazer deploy automático do Dokploy no Render.com.

## 🚀 Como fazer o deploy

### 1. Configurar no Render.com

1. Acesse [render.com](https://render.com) e faça login
2. Clique em "New +" e selecione "Web Service"
3. Conecte este repositório GitHub
4. Configure as seguintes opções:

### Configurações básicas

- **Name**: `dokploy-app` (ou o nome que preferir)
- **Environment**: `Docker`
- **Region**: Escolha a região mais próxima
- **Branch**: `main`
- **Root Directory**: deixe em branco
- **Dockerfile Path**: `./Dockerfile`

### Configurações avançadas

- **Build Command**: deixe em branco (usa o Dockerfile)
- **Start Command**: deixe em branco (usa o CMD do Dockerfile)

### 2. Configurar variáveis de ambiente

No painel do Render, vá em "Environment" e adicione as seguintes variáveis:

### Obrigatórias

```env
DOKPLOY_SECRET_KEY=gere_uma_chave_secreta_forte_aqui
```

### Opcionais

```env
DOKPLOY_HOST=0.0.0.0
LOG_LEVEL=info
DOKPLOY_SSL=true
```

**⚠️ IMPORTANTE**: Para gerar uma chave secreta forte, use:

```bash
openssl rand -hex 32
```

### 3. Deploy

1. Clique em "Create Web Service"
2. O Render irá automaticamente:
   - Fazer build do Docker container
   - Instalar o Dokploy
   - Iniciar o serviço

### 4. Acessar o Dokploy

Após o deploy bem-sucedido:

1. Acesse a URL fornecida pelo Render (ex: `https://seu-app.onrender.com`)
2. Complete a configuração inicial do Dokploy
3. Crie sua conta de administrador

## 🔧 Estrutura do projeto

```text
dokploy_n8n/
├── Dockerfile              # Container principal
├── start.sh                # Script de inicialização
├── install-dokploy.sh      # Script de instalação do Dokploy
├── .env.example            # Exemplo de variáveis de ambiente
├── README.md               # Esta documentação
└── LICENSE                 # Licença MIT
```

## 📋 Recursos incluídos

- ✅ Docker configurado
- ✅ Dokploy instalação automática
- ✅ Scripts de inicialização otimizados
- ✅ Configuração de ambiente flexível
- ✅ Suporte a SSL/TLS
- ✅ Logs configuráveis

## 🛠️ Solução de problemas

### Container não inicia

1. Verifique os logs no painel do Render
2. Confirme se todas as variáveis de ambiente estão configuradas
3. Verifique se a `DOKPLOY_SECRET_KEY` foi definida

### Dokploy não carrega

1. Aguarde alguns minutos após o deploy (primeira inicialização demora mais)
2. Verifique se a porta está correta (deve ser 3000 ou a definida em PORT)
3. Confirme se o Docker daemon iniciou corretamente nos logs

### Erro de permissões

- O container já está configurado com as permissões necessárias
- Se persistir, verifique os logs para detalhes específicos

## 🔄 Atualizações

Para atualizar o Dokploy:

1. Faça push das alterações para o repositório
2. O Render fará automaticamente o redeploy
3. O script verificará e atualizará o Dokploy se necessário

## 📞 Suporte

- [Documentação oficial do Dokploy](https://dokploy.com/docs)
- [Documentação do Render](https://render.com/docs)
- [Issues do GitHub](https://github.com/lordjack/dokploy_n8n/issues)

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

**Desenvolvido por**: Jackson Meires  
**Repositório**: [dokploy_n8n](https://github.com/lordjack/dokploy_n8n)