FROM registry.access.redhat.com/ubi9/ubi

# Set environment variables to avoid interactive prompts
ENV LANG=en_US.UTF-8

# Update packages and install essential Linux tools using dnf (Red Hat's package manager)
RUN dnf update -y && dnf install -y \
    # Basic system tools
    sudo \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    file \
    unzip \
    zip \
    tar \
    gzip \
    # Network tools
    net-tools \
    iputils \
    nmap-ncat \
    tcpdump \
    telnet \
    openssh-clients \
    # Process and system monitoring
    procps-ng \
    lsof \
    strace \
    # Text processing tools (most are built-in)
    grep \
    sed \
    gawk \
    less \
    findutils \
    # Development tools
    gcc \
    gcc-c++ \
    make \
    cmake \
    python3 \
    python3-pip \
    nodejs \
    npm \
    # System utilities
    cronie \
    systemd \
    which \
    man-db \
    man-pages \
    # Additional useful tools
    jq \
    bc \
    time \
    util-linux \
    screen \
    tmux \
    rsync \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Create a learning user with sudo privileges
ARG USERNAME=learner
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user with passwordless sudo access
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up a proper shell environment
RUN echo 'export PS1="\u@\h:\w$ "' >> /home/$USERNAME/.bashrc \
    && echo 'alias ll="ls -alF"' >> /home/$USERNAME/.bashrc \
    && echo 'alias la="ls -A"' >> /home/$USERNAME/.bashrc \
    && echo 'alias l="ls -CF"' >> /home/$USERNAME/.bashrc

# Switch to the learning user
USER $USERNAME
WORKDIR /home/$USERNAME

# Set the default command
CMD ["/bin/bash"]
