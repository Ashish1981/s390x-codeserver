#FROM s390x/node
FROM  ashish1981/s390x-codeserver:intmdn


ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    TZ=America/Los_Angeles \
    # adding a sane default is needed since we're not erroring out via exec.
    CODER_PASSWORD="coder" \
    oc_version="v3.11.0" \
    oc_version_commit="0cbc58b" \
    PATH="${PATH}:/home/coder/.local/bin"

COPY exec /opt

RUN  \
    apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && \
    apt-get install -y curl locales gnupg2 tzdata && locale-gen en_US.UTF-8 && \
#    curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get upgrade -y && \
    apt-get install -y  \
    sudo \
    curl \
    openssl \
    net-tools \
    openvpn \
    jq \
    git \
    tree \
    locales \ 
    curl \
    dumb-init \
    wget \
    httpie \
 #   nodejs \
    python \
    python3-pip \
    joe \
    ansible \
    bash-completion \
    openssh-client \
    default-jdk && \
    npm install -g npm && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* 

RUN locale-gen en_US.UTF-8 && \
# #     cd /tmp && \
# #     # install code-server
# #     wget -O - $(curl -s https://api.github.com/repos/cdr/code-server/releases/latest |  jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url') | tar -xzv --strip 1 -C /usr/local/bin/ && \
# #     # Ashish added
# #     # curl -fsSL https://code-server.dev/install.sh | sh &&  \
# #     # yarn global add code-server \
# #     # npm install -g code-server --force \
# #     # Ashish added    
# #     # install openshift/kubernetes client tools
# #     # wget -O - https://github.com/openshift/origin/releases/download/${oc_version}/openshift-origin-client-tools-${oc_version}-${oc_version_commit}-linux-64bit.tar.gz | tar -xzv --strip 1 openshift-origin-client-tools-${oc_version}-${oc_version_commit}-linux-64bit/oc openshift-origin-client-tools-${oc_version}-${oc_version_commit}-linux-64bit/kubectl && \
# #     # mv oc kubectl /usr/bin/ && \
# #     # /usr/bin/oc completion bash >> /etc/bash_completion.d/oc_completion && \
# #     # /usr/bin/kubectl completion bash >> /etc/bash_completion.d/kubectl_completion && \
# #     # # for openvpn
# #     # mkdir -p /dev/net && \
# #     # mknod /dev/net/tun c 10 200 && \
# #     # chmod 600 /dev/net/tun && \
# #     # echo "user ALL=(ALL) NOPASSWD: /usr/sbin/openvpn --config /home/coder/projects/.openvpn/openvpn-client-conf.ovpn" >> /etc/sudoers.d/openvpn-client && \
# #     # add user coder
    adduser --disabled-password --gecos '' coder && \
    echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd && \
    chmod g+rw /home/coder && \
    chmod a+x /opt/exec && \
    chgrp -R 0 /home/coder /etc/ansible && \
    chmod -R g=u /home/coder /etc/ansible /etc/resolv.conf && \
    chmod g=u /etc/passwd /etc/resolv.conf /etc/ssl/certs/ca-certificates.crt

ENV LC_ALL=en_US.UTF-8

WORKDIR /home/coder

USER coder

RUN mkdir -p projects && mkdir -p certs && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash && \
    sudo chmod -R g+rw projects/ && \
    sudo chmod -R g+rw certs/ && \
    sudo chmod -R g+rw .nvm && \
    sudo rm -frv .config/ && \
    sudo chgrp -R 0 /home/coder

COPY entrypoint /home/coder
RUN sudo chmod g+rx /home/coder/entrypoint

VOLUME ["/home/coder/projects", "/home/coder/certs"];

USER 10001

ENTRYPOINT ["/home/coder/entrypoint"]

EXPOSE 9000 8080

CMD ["/opt/exec"]