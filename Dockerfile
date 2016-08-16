FROM ubuntu:latest
MAINTAINER arthurkiller "arthur-lee@qq.com"
# this docker file is used to try building a work environment

RUN apt-get -y update
RUN apt-get install -y --no-install-recommends \
        build-essential vim sudo cmake unzip libtool \
        autotools-dev automake autoconf \
        curl tar locales wget python python-dev libxml2-dev libxslt-dev \
        git gcc fish tmux golang \
        openssh-server apt-transport-https ca-certificates

##set the time && add alias into profile
RUN echo 'alias ll="ls -lah --color=auto"' >> /etc/profile
RUN apt-get install -y  --fix-missing software-properties-common
RUN echo "Asia/shanghai" > /etc/timezone
RUN cp /usr/share/zoneinfo/PRC /etc/localtime

# add user arthur && add sudo to arthur
RUN useradd arthur 
RUN echo "arthur  ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN echo "/usr/bin/fish" >> /etc/shells
RUN mkdir /home/arthur 


# change the shell into fish
RUN echo "arthur:arthur"| chpasswd
RUN echo "root:toor"| chpasswd
RUN sed -i "/arthur/d" /etc/passwd && echo "arthur:x:1000:1000::/home/arthur:/usr/bin/fish" >> /etc/passwd
RUN mkdir /home/arthur/.config && mkdir /home/arthur/.config/fish && touch /home/arthur/.config/fish/config.fish
RUN echo "set -x GOPATH $HOME/golang" >> /home/arthur/.config/fish/config.fish
RUN echo "set -x PATH $GOPATH/bin $PATH" >> /home/arthur/.config/fish/config.fish

# make the go env
RUN mkdir /home/arthur/golang
#RUN mkdir /home/arthur/golang && chown -R arthur:arthur /home/arthur/golang && chmod 775 /home/arthur/golang
RUN echo "export GOPATH=/home/arthur/golang" >> /etc/profile
RUN echo "export PATH=$GOPATH/bin:$PATH" >> /etc/profile
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/lib" >> etc/profile
RUN git clone https://github.com/google/protobuf.git /home/arthur/protobuf 
RUN (cd /home/arthur/protobuf && git checkout 3.0.0-pre && env LC_ALL=C ./autogen.sh && ./configure && make && make install)
#RUN wget https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz /home/arthur/
#RUN (cd /home/arthur/protobuf-2.6.1 && ./configure && make && make install)

# get my vimrc
RUN git clone https://github.com/arthurkiller/VIMrc /home/arthur/VIMrc
RUN (cd /home/arthur/VIMrc && su arthur && python3 install.py)
RUN git clone https://github.com/arthurkiller/MyGoBin /home/arthur/MyGoBin
RUN (cd /home/arthur/MyGoBin && ./install.sh)
#RUN chown -R arthur:arthur /home/arthur/VIMrc && chmod 775 /home/arthur/VIMrc
#RUN mkdir /home/arthur && chown -R arthur:arthur /home/arthur && chmod -R 755 /home/arthur
RUN chown -R arthur:arthur /home/arthur && chmod -R 755 /home/arthur

## I have used others dockerfile and do not know what will take place
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

#start the sshd server
RUN mkdir /var/run/sshd
CMD ["/usr/sbin/sshd", "-D"]
