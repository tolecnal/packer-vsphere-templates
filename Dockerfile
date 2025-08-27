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

# Set versions
ARG PACKER_VERSION=1.14.1
ARG GOVC_VERSION=0.52.0

# Download and install Packer
RUN wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod +x /usr/local/bin/packer

# Download and install govc
RUN wget -q https://github.com/vmware/govmomi/releases/download/v${GOVC_VERSION}/govc_Linux_x86_64.tar.gz && \
    tar -xzf govc_Linux_x86_64.tar.gz && \
    mv govc /usr/local/bin/ && \
    rm govc_Linux_x86_64.tar.gz && \
    chmod +x /usr/local/bin/govc

# Install Packer vsphere plugin
RUN packer plugins install github.com/hashicorp/vsphere

# Verify installations
RUN packer version && govc version && packer plugins installed

# Set working directory
WORKDIR /workspace

# Copy project files (this will be overridden by GitLab CI)
COPY . /workspace/

# Default command
CMD ["bash"]
