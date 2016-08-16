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

## I have used others dockerfile and do not know what will take place
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN mkdir /var/run/sshd

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
RUN echo "export GOPATH=/home/arthur/golang" >> /etc/profile
RUN echo "export PATH=$GOPATH/bin:$PATH" >> /etc/profile
RUN echo "set -x GOPATH $HOME/golang" >> /home/arthur/.config/fish/config.fish
RUN echo "set -x PATH $GOPATH/bin $PATH" >> /home/arthur/.config/fish/config.fish
RUN git config --global alias.list "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
RUN git config --global user.email "arthur-lee@qq.com"
RUN git config --global user.name "arthur"


# make the go env
RUN mkdir /home/arthur/golang
RUN chown -R arthur:arthur /home/arthur && chmod -R 755 /home/arthur
#RUN mkdir /home/arthur/golang && chown -R arthur:arthur /home/arthur/golang && chmod 775 /home/arthur/golang
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/lib" >> etc/profile

# get my vimrc
USER arthur
RUN git clone https://github.com/google/protobuf.git /home/arthur/protobuf 
RUN (cd /home/arthur/protobuf && git checkout 3.0.0-pre && env LC_ALL=C ./autogen.sh && ./configure && make && make install)
RUN git clone https://github.com/arthurkiller/VIMrc /home/arthur/VIMrc
RUN bash /home/arthur/VIMrc/install.sh
RUN git clone https://github.com/arthurkiller/MyGoBin /home/arthur/MyGoBin
RUN mkdir /home/arthur/golang/bin
RUN cp /home/arthur/MyGoBin/* /home/arthur/golang/bin/
#RUN chown -R arthur:arthur /home/arthur/VIMrc && chmod 775 /home/arthur/VIMrc
#RUN mkdir /home/arthur && chown -R arthur:arthur /home/arthur && chmod -R 755 /home/arthur

EXPOSE 22

#start the sshd server
CMD ["/usr/sbin/sshd", "-D"]
