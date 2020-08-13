FROM  debian:10

ENV TC_DIR     /usr/local/trinitycore
ENV TC_REPO    git://github.com/TrinityCore/TrinityCore.git
ENV TC_DB_URL  https://github.com/TrinityCore/TrinityCore/releases


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y \
  git \
  wget \
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
  p7zip \
  default-libmysqlclient-dev \
  p7zip-full

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

RUN mkdir -p $TC_DIR && \
  cd $TC_DIR && \
  git clone -b 3.3.5 $TC_REPO

ADD build_core.sh /etc/build_core.sh
RUN chmod +x /etc/build_core.sh
RUN /etc/build_core.sh

ADD extract_maps.sh /etc/extract_maps.sh
RUN chmod +x /etc/extract_maps.sh

ADD entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh

RUN cd $TC_DIR/bin && \
    wget $TC_DB_URL -O /tmp/latestver.out && \
    LATEST_VER=$(grep "TDB_full_world_335" /tmp/latestver.out | head -1 | awk -F\" '{print $2}') && \
    wget http://github.com$LATEST_VER && \
    7z x *.7z && \
    rm *.7z

ENV CLIENT_DIR /opt/wow-client
ENV MAPS_DIR   /usr/local/trinitycore/data
ENV CONF_DIR   /usr/local/trinitycore/etc

ENTRYPOINT  ["/etc/entrypoint.sh"]

ENV DEBIAN_FRONTEND newt
