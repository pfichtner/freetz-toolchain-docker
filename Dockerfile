FROM ubuntu:14.04

ARG BUILD_USER=builduser

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
            locales \
            pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake \
            libtool make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar realpath \
            perl libstring-crc32-perl ruby ruby1.9 gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev \
    && \
    \
    locale-gen en_US.utf8 && locale-gen de_DE.UTF-8 && update-locale && \
    \
    CAX3="/usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt" && \
    for x in $(find /etc/ssl/certs/ ! -type d); do [ "$(realpath $x)"  = "/usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt" ] && CAX3="$CAX3 $x"; done ; rm -f $CAX3 && \
    \
    URL="https://github.com/tianon/gosu/releases/download/1.14/" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && \
    wget -qO gosu     "$URL/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -qO gosu.asc "$URL/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }').asc" && \
    wget -qO - https://keys.openpgp.org/vks/v1/by-fingerprint/B42F6819007F00F88E364FD4036A9C25BF357DD4 | gpg --import - && \
    gpg --batch --verify gosu.asc gosu && \
    chmod +x gosu && mv gosu /usr/local/bin && \
    cd - && rm -rf "$DIR" && \
    \
    URL="https://github.com/facebook/zstd/releases/download/v1.4.9/zstd-1.4.9.tar.gz" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && \
    wget -qO- "$URL" | tar xzvf - --strip-components=1 && make && make install && \
    cd - && rm -rf "$DIR" && \
    \
    URL="https://ftp.gnu.org/gnu/cpio/cpio-2.12.tar.bz2" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && \
    wget -qO- "$URL" | tar xjvf - --strip-components=1 && ./configure && make && make install && \
    cd - && rm -rf "$DIR" && \
    \
    URL="https://ftp.gnu.org/gnu/make/make-3.82.tar.bz2" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && \
    wget -qO- "$URL" | tar xjvf - --strip-components=1 && ./configure && make && make install && \
    cd - && rm -rf "$DIR" && \
    \
    URL="https://ftp.osuosl.org/pub/blfs/conglomeration/cmake/cmake-3.4.3.tar.gz" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && \
    wget -qO- "$URL" | tar xzvf -  --strip-components=1 && ./configure && make && make install && \
    cd - && rm -rf "$DIR" && \
    \
    useradd -M -G sudo -d /workspace $BUILD_USER && \
    mkdir -p /workspace && chown -R $BUILD_USER /workspace && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

