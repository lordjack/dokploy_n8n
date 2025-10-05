# Dockerfile para deploy do Dokploy no Render.com
FROM ubuntu:22.04

# Instalar dependências básicas
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    sudo \
    systemctl \
    && rm -rf /var/lib/apt/lists/*

# Instalar Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Instalar Node.js (necessário para algumas funcionalidades do Dokploy)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Criar usuário dokploy
RUN useradd -m -s /bin/bash dokploy
RUN usermod -aG docker dokploy
RUN echo "dokploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Criar diretórios necessários
RUN mkdir -p /etc/dokploy
RUN mkdir -p /var/lib/dokploy
RUN chown -R dokploy:dokploy /etc/dokploy /var/lib/dokploy

# Copiar scripts de inicialização
COPY start.sh /usr/local/bin/start.sh
COPY install-dokploy.sh /usr/local/bin/install-dokploy.sh
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/install-dokploy.sh

# Expor porta padrão do Dokploy
EXPOSE 3000

# Definir usuário
USER dokploy
WORKDIR /home/dokploy

# Comando para iniciar o container
CMD ["/usr/local/bin/start.sh"]