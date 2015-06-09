FROM jenkins:1.609.1
MAINTAINER Niek Palm "dev.npalm@gmail.com"

USER root

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* \
	&& curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

COPY plugins.txt /usr/share/jenkins/plugins.txt
COPY plugins.sh /usr/local/bin/plugins.sh
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

COPY jenkins.sh /usr/local/bin/jenkins.sh

EXPOSE 8443

ENTRYPOINT ["/usr/local/bin/jenkins.sh"]
