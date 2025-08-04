FROM registry.access.redhat.com/ubi9/ubi

ENV LANG=en_US.UTF-8
ENV USERNAME=learner
ENV USER_UID=1000
ENV USER_GID=1000

# Enable EPEL and CRB, then install Linux tools (adjust as needed if some fail)
RUN dnf install -y 'dnf-command(config-manager)' \
    && dnf config-manager --set-enabled crb \
    && dnf install -y epel-release \
    && dnf update -y \
    && dnf install -y \
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
        net-tools \
        iputils \
        nmap-ncat \
        tcpdump \
        telnet \
        openssh-clients \
        procps-ng \
        lsof \
        strace \
        grep \
        sed \
        gawk \
        less \
        findutils \
        gcc \
        gcc-c++ \
        make \
        cmake \
        python3 \
        python3-pip \
        nodejs \
        npm \
        cronie \
        systemd \
        which \
        man-db \
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
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up aliases and a friendly prompt
RUN echo 'export PS1="[\u@\h \w]\\$ "' >> /home/$USERNAME/.bashrc \
    && echo "alias ll='ls -alF'" >> /home/$USERNAME/.bashrc \
    && echo "alias la='ls -A'" >> /home/$USERNAME/.bashrc \
    && echo "alias l='ls -CF'" >> /home/$USERNAME/.bashrc

USER $USERNAME
WORKDIR /home/$USERNAME

CMD ["/bin/bash"]
