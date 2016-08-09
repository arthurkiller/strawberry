FROM ubuntu:latest
MAINTAINER arthurkiller "arthur-lee@qq.com"
# this docker file is used to try building a work environment

RUN apt-get -y update
RUN apt-get install -y --no-install-recommends \
        build-essential vim sudo cmake \
        autotools-dev automake autoconf \
        curl tar locales wget python \
        git gcc fish tmux golang \
        openssh-server apt-transport-https ca-certificates
RUN echo "Asia/Beijing" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    echo 'alias ll="ls -lah --color=auto"' >> /etc/bash.bashrc
RUN apt-get install -y  --fix-missing software-properties-common
#RUN apt-get -y install golang

RUN echo "/usr/bin/fish" >> /etc/shells
RUN chsh -s bash
RUN useradd arthur 
RUN echo "arthur  ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN mkdir /home/arthur && chown -R arthur:arthur /home/arthur && chmod 755 /home/arthur
RUN echo "arthur:arthur"| chpasswd
RUN echo "root:toor"| chpasswd
RUN mkdir /var/run/sshd
RUN sed -i '0,$s/\/bin\/sh/\usr\/bin\/fish''/g' /etc/passwd
RUN sed -i "s#\/bin\/sh#\/usr\/bin\/fish# g" /etc/passwd

# make the go env
RUN mkdir /home/arthur/golang && chown -R arthur:arthur /home/arthur/golang && chmod 775 /home/arthur/golang
RUN echo "export GOPATH=$HOME/golang" >> /etc/profile
RUN echo "export PATH=$HOME/bin:$GOPATH/bin:$PATH" >> etc/profile

# get my vimrc
RUN su arthur && git clone https://github.com/arthurkiller/VIMrc /home/arthur/VIMrc
RUN chown -R arthur:arthur /home/arthur/VIMrc && chmod 775 /home/arthur/VIMrc

## I have used others dockerfile and do not know what will take place
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ENV LC_ALL en_US.utf8
EXPOSE 22

#start the sshd server
CMD ["/usr/sbin/sshd", "-D"]
