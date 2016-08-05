FROM ubuntu:latest
RUN useradd -u 777 arthur
RUN apt-get -y update
RUN apt-get install --force-yes -y --no-install-recommends \
        build-essential \
        autotools-dev automake autoconf \
        curl tar xz-utils locales wget \
        git subversion mercurial \
        openssh-server apt-transport-https ca-certificates 
RUN echo "Europe/Berlin" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc
#RUN apt-get -y install fish
#RUN chsh -s /usr/bin/fish arthur
#RUN apt-get -y install golang
RUN echo "liziangarthur"| passwd arthur -S
RUN echo "toor"| passwd root -S 
RUN mkdir /var/run/sshd
ENV LC_ALL en_US.utf8
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
