FROM rockylinux:9

ENV LANG=en_US.UTF-8
ENV USERNAME=learner
ENV USER_UID=1000
ENV USER_GID=1000

RUN dnf install -y dnf-plugins-core \
    && dnf install -y --allowerasing \
        sudo \
        curl \
        wget \
        git \
        vim \
        nano \
        file \
        unzip \
        e2fsprogs \
        zip \
        tar \
        gzip \
        net-tools \
        iputils \
        nmap-ncat \
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
        rsync \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf update -y \
    && dnf install -y --allowerasing \
        htop \
        tree \
        tcpdump \
        telnet \
        screen \
        tmux \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN echo 'export PS1="[\u@\h \w]\\$ "' >> /home/$USERNAME/.bashrc \
    && echo "alias ll='ls -alF'" >> /home/$USERNAME/.bashrc \
    && echo "alias la='ls -A'" >> /home/$USERNAME/.bashrc \
    && echo "alias l='ls -CF'" >> /home/$USERNAME/.bashrc

USER $USERNAME
WORKDIR /home/$USERNAME

CMD ["/bin/bash"]
