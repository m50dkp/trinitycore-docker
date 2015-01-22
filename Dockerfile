FROM	debian:latest

ENV	TC_DIR	/usr/local/trinitycore
ENV	TC_REPO	git://github.com/TrinityCore/TrinityCore.git

ENV	DEBIAN_FRONTEND	noninteractive

RUN	apt-get update && \
	apt-get install -y \
	build-essential \
	autoconf \
	libtool \
	gcc \
	g++ \
	make \
	cmake \
	git-core \
	wget \
	p7zip-full \
	libncurses5-dev \
	openssl \
	libssl-dev \
	mysql-server \
	mysql-client \
	libmysqlclient15-dev \
	libmysql++-dev \
	libreadline6-dev \
	zlib1g-dev \
	libbz2-dev \
	libboost-dev \
	libboost-thread-dev \
	libboost-system-dev \
	libboost-filesystem-dev \
	libboost-program-options-dev

RUN	mkdir -p $TC_DIR && \
	cd $TC_DIR && \
	git clone -b 3.3.5 --depth 1 $TC_REPO

ADD	build.sh /etc/build.sh
RUN	/etc/build.sh
RUN	rm -rf $TC_DIR

ADD	extract_maps.sh /etc/extract_maps.sh
RUN	chmod +x /etc/extract_maps.sh

ENV	DEBIAN_FRONTEND	newt
