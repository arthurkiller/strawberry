FROM debian:latest
RUN useradd -u 777 arthur
RUN apt-get -y update
RUN apt-get install --force-yes -y --no-install-recommends \
        build-essential \
        autotools-dev automake autoconf \
        curl tar xz-utils locales wget \
        git subversion mercurial \
        openssh-server apt-transport-https ca-certificates 
#RUN apt-get -y install fish
#RUN chsh -s /usr/bin/fish arthur
RUN set LANG=en_US.utf8
#RUN apt-get -y install golang
RUN echo "liziangarthur"| passwd arthur -S
RUN echo "toor"| passwd root -S 
#RUN mkdir /var/run/sshd
EXPOSE 22
