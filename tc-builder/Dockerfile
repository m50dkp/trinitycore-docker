# Using nodejs since it's debian by default and we can script easily.
FROM node:14-buster

# https://trinitycore.atlassian.net/wiki/spaces/tc/pages/10977309/Linux+Core+Installation
# Plus jq for scripting

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
  jq \
  mariadb-server \
  p7zip-full \
  default-libmysqlclient-dev \
  && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
  && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100 \
  && rm -rf /var/lib/apt/lists/*

# Used to help worldserver and authserver wait for the database to be ready
RUN npm install -g wait-port

# Reasonable defaults
ENV PATH="/hostfs/bin:$PATH"
WORKDIR /hostfs
ENTRYPOINT [ "/hostfs/bin/_bash-entrypoint" ]