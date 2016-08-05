FROM ubuntu:latest
MAINTAINER arthurkiller "arthur-lee@qq.com"

# this docker file is used to try building a work environment

RUN echo "deb http://mirrors.163.com/ubuntu precise main universe" > /etc/apt/sources.list
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
RUN echo "arthur:arthur"| chpasswd
RUN echo "root:toor"| chpasswd
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
ENV LC_ALL en_US.utf8
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
