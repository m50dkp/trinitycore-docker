# Using nodejs since it's debian by default and we can script easily.
FROM node:14-buster

RUN apt-get update \
  && apt-get install -y \
  git \
  clang \
  cmake \
  make \
  gcc \
  g++ \
  libmariadbclient-dev \
  libssl-dev \
  libbz2-dev \
  libreadline-dev \
  libncurses-dev \
  libboost-all-dev \
  mariadb-server \
  p7zip-full \
  default-libmysqlclient-dev \
  && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
  && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

RUN npm install -g wait-port

# Reasonable defaults
ENV PATH="/hostfs/bin:$PATH"
WORKDIR /hostfs
ENTRYPOINT [ "/hostfs/bin/bash-entrypoint" ]