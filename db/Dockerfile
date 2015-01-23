FROM mariadb:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y \
  git-core \
  wget \
  p7zip-full

ADD install.sh /etc/db/install.sh
RUN chmod +x /etc/db/install.sh

ADD entrypoint.sh /etc/db/entrypoint.sh
RUN chmod +x /etc/db/entrypoint.sh

ENTRYPOINT ["/etc/db/entrypoint.sh"]

ENV DEBIAN_FRONTEND newt
