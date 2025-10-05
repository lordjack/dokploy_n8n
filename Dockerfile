# Dockerfile para deploy do Dokploy no Render.com
FROM ubuntu:22.04

# Definir variáveis de ambiente para evitar prompts interativos
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Atualizar e instalar dependências básicas
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    sudo \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js primeiro (necessário para Dokploy)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Instalar Docker (opcional, pode falhar no Render)
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    bash get-docker.sh || echo "Docker installation failed, continuing..." && \
    rm -f get-docker.sh

# Criar usuário dokploy e configurar permissões
RUN useradd -m -s /bin/bash -G sudo dokploy && \
    echo "dokploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG docker dokploy 2>/dev/null || true

# Criar diretórios necessários com permissões corretas
RUN mkdir -p /etc/dokploy /var/lib/dokploy /home/dokploy/.config && \
    chown -R dokploy:dokploy /etc/dokploy /var/lib/dokploy /home/dokploy

# Copiar scripts de inicialização
COPY start.sh /usr/local/bin/start.sh
COPY install-dokploy.sh /usr/local/bin/install-dokploy.sh
COPY start-standalone.sh /usr/local/bin/start-standalone.sh
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/install-dokploy.sh /usr/local/bin/start-standalone.sh

# Expor porta padrão do Dokploy
EXPOSE 3000

# Mudar para usuário dokploy
USER dokploy
WORKDIR /home/dokploy

# Comando para iniciar o container
CMD ["/usr/local/bin/start.sh"]