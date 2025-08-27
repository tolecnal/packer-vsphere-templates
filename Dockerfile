FROM alpine:3.18

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    unzip \
    ca-certificates \
    openssh-client \
    git

# Set Packer version
ARG PACKER_VERSION=1.14.1

# Download and install Packer
RUN wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod +x /usr/local/bin/packer

# Verify Packer installation
RUN packer version

# Set working directory
WORKDIR /workspace

# Copy project files (this will be overridden by GitLab CI)
COPY . /workspace/

# Default command
CMD ["bash"]