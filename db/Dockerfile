FROM	mariadb:latest

ENV	TC_DIR	/usr/local/trinitycore
ENV	TC_REPO	git://github.com/TrinityCore/TrinityCore.git
ENV	TC_DB	https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.57/TDB_full_335.57_2014_10_19.7z
ENV	DEBIAN_FRONTEND noninteractive

RUN	apt-get update && \
	apt-get install -y \
	git-core \
	wget \
	p7zip-full

RUN     mkdir -p $TC_DIR && \
	cd $TC_DIR && \
	git clone -b 3.3.5 --depth 1 $TC_REPO

RUN	mkdir -p $TC_DIR/sql && \
	cd $TC_DIR/sql && \
	wget 'https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.57/TDB_full_335.57_2014_10_19.7z' && \
	7z x *.7z

ADD	build.sh /etc/db/build.sh
RUN	mysqld_safe && \
	/etc/db/build.sh && \
	rm -rf $TC_DIR

ENV	DEBIAN_FRONTEND newt