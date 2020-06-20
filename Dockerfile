FROM debian:latest

MAINTAINER luu135@qq.com

RUN apt-get -yqq update;apt-get install -yqq openssh-server
RUN sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN mkdir /run/sshd
CMD ["/usr/sbin/sshd", "-D"]
