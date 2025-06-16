FROM ghcr.io/iximiuz/labs/rootfs:ubuntu-docker

# Switch to the root user to do install things
USER root


# Setup apt packages for general tools
RUN apt update && apt install -y wget curl git mount openssl unzip iproute2\
 iputils-ping iputils-arping traceroute dnsutils tcpdump libcap2-bin ruby whois\
 socat apt-transport-https ca-certificates curl software-properties-common\
  openssh-server openssh-client python3 python-is-python3 vim nano net-tools nmap


#Install kubectl 1.30
RUN curl -OL https://dl.k8s.io/v1.30.3/bin/linux/amd64/kubectl && \
chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

# Install amicontained
RUN curl -OL https://github.com/genuinetools/amicontained/releases/download/v0.4.9/amicontained-linux-amd64 && \
mv amicontained-linux-amd64 /usr/local/bin/amicontained && chmod +x /usr/local/bin/amicontained

# Install rbac-tool
RUN curl -OL https://github.com/alcideio/rbac-tool/releases/download/v1.19.0/rbac-tool_v1.19.0_linux_amd64.tar.gz && \
tar -xzvf rbac-tool_v1.19.0_linux_amd64.tar.gz && mv rbac-tool /usr/local/bin && chmod +x /usr/local/bin/rbac-tool && \
rm -f rbac-tool_v1.19.0_linux_amd64.tar.gz LICENSE README.md

#Get kdigger
RUN curl -OL https://github.com/quarkslab/kdigger/releases/download/v1.5.1/kdigger-linux-amd64 && \
mv kdigger-linux-amd64 /usr/local/bin/kdigger && chmod +x /usr/local/bin/kdigger

#Get Docker CLI
RUN curl -OL https://download.docker.com/linux/static/stable/x86_64/docker-27.1.1.tgz && tar -xzvf docker-27.1.1.tgz && \
cp docker/docker /usr/local/bin && chmod +x /usr/local/bin/docker && rm -rf docker/ && rm -f docker-27.1.1.tgz 

#Get nerdctl
RUN curl -OL https://github.com/containerd/nerdctl/releases/download/v1.7.6/nerdctl-1.7.6-linux-amd64.tar.gz && \
tar -xzvf nerdctl-1.7.6-linux-amd64.tar.gz && mv nerdctl /usr/local/bin && chmod +x /usr/local/bin/nerdctl && \
rm -f nerdctl-1.7.6-linux-amd64.tar.gz && rm -f containerd-rootless-setuptool.sh && rm -f containerd-rootless.sh

#Get crictl
RUN curl -OL https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.30.1/crictl-v1.30.1-linux-amd64.tar.gz && \
tar -xzvf crictl-v1.30.1-linux-amd64.tar.gz && mv crictl /usr/local/bin && chmod +x /usr/local/bin/crictl && \
rm -f crictl-v1.30.1-linux-amd64.tar.gz

#Get JWT-CLI
RUN curl -OL https://github.com/mike-engel/jwt-cli/releases/download/6.2.0/jwt-linux.tar.gz && \
tar -xzvf jwt-linux.tar.gz && mv jwt /usr/local/bin && chmod +x /usr/local/bin/jwt && rm -f jwt-linux.tar.gz

#Get k9s
RUN curl -OL https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_Linux_amd64.tar.gz && \
tar -zxvf k9s_Linux_amd64.tar.gz && mv k9s /usr/local/bin && chmod +x /usr/local/bin/k9s && rm -f k9s_Linux_amd64.tar.gz LICENSE README.md

#Setup Starship prompt
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y && mkdir /home/laborant/.config

#Add starship to the bashrc
RUN echo 'eval "$(starship init bash)"' >> /home/laborant/.bashrc

#Copy the starship config
COPY /config_files/starship.toml /home/laborant/.config/starship.toml

#Get Kubectx and Kubens
RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx && \
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

#Get Kubeletctl
RUN curl -LO https://github.com/cyberark/kubeletctl/releases/download/v1.13/kubeletctl_linux_amd64 && \
chmod a+x ./kubeletctl_linux_amd64 && \
mv ./kubeletctl_linux_amd64 /usr/local/bin/kubeletctl

# Allow root login to SSH so our SSH daemon works
RUN sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config


# Setup the manifests from the repository
RUN mkdir /manifests
COPY /manifests/* /manifests/

# Setup the scripts from the repository
RUN mkdir /scripts
COPY /scripts/* /scripts/

# Switch back to Laborant at the end
USER laborant
