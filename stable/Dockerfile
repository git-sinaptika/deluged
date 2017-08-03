#Maintainer info@sinaptika.net
#deluge http://deluge-torrent.org/
#deluged image
FROM alpine:3.6

ENV \
#Enviroment variables for building the image.
 DELUGE_VERSION="1.3.15" \
 LIBTORRENT_VERSION="1.0.11" \
 _LIBTORRENT_VERSION="1_0_11" \
 D_DIR="/opt/deluge" \
 D_USER="deluge" \
 D_GROUP="deluge" \
 D_D_PORT="58846" \
 D_D_INCOMING_PORT="50100" \
#Enviroment variables for running the container.
#Pass at docker create or docker run (-e VARIABLE=value).
 TZ="Europe/London" \
 D_UID="1000" \
 D_GID="1000" \
 D_D_LOG_LEVEL="warn"

 RUN \
#Create directory structure and add user:group.
  mkdir -p \
   ${D_DIR} \
   ${D_DIR}/config \
   ${D_DIR}/complete \
   ${D_DIR}/downloads && \
  addgroup -g \
   ${D_GID} -S ${D_GROUP} && \
  adduser \
   -h ${D_DIR} \
   -g "Deluge system user" \
   -G ${D_GROUP} \
   -S -D \
   -u ${D_UID} ${D_USER}

COPY \
 scripts/deluged-pass.sh \
 scripts/docker-entrypoint.sh \
 /usr/bin/

 RUN \
#Libtorrent
  apk add --no-cache --virtual .build_libtorrent \
   wget ca-certificates alpine-sdk boost-dev libressl-dev python2-dev && \
  cd /root && \
  wget -qO-\
   https://github.com/arvidn/libtorrent/releases/download/libtorrent-${_LIBTORRENT_VERSION}/libtorrent-rasterbar-${LIBTORRENT_VERSION}.tar.gz | \
   tar xvz && \
  cd libtorrent-rasterbar-${LIBTORRENT_VERSION} && \
  ./configure \
   --build=$CBUILD \
   --host=$CHOST \
   --prefix=/usr \
   --enable-python-binding \
   --with-boost-system=boost_system \
   --enable-debug=no \
   --disable-debug \
   --quiet && \
  make && \
  make install-strip && \
  rm -rf /usr/lib/libtorrent-rasterbar.a && \
  strip /usr/lib/python2.7/site-packages/libtorrent.so && \
  strip /usr/lib/libtorrent-rasterbar.so && \
  rm -rf libtorrent-rasterbar-${LIBTORRENT_VERSION} && \
  apk del .build_libtorrent && \
  apk add --no-cache --virtual .runtime_libtorrent \
   boost-python boost-system libgcc libstdc++ python2 && \
#deluge
  apk add --no-cache --virtual .system \
   tzdata su-exec tini pwgen unrar && \
  apk add --no-cache --virtual .build_deluge \
   geoip openssl py2-pip intltool py-mako && \
  apk add --no-cache --virtual .runtime_deluge \
   py-setuptools py2-openssl py-twisted py2-geoip && \
#automat package needed for deluge-web only
  pip install --no-cache-dir \
   chardet pyxdg service_identity incremental constantly packaging && \
  wget \
   https://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz -O \
   /tmp/GeoIP.dat.gz && gunzip /tmp/GeoIP.dat.gz && \
  mv \
   /tmp/GeoIP.dat /usr/share/GeoIP && \
   wget -qO- \
   http://download.deluge-torrent.org/source/deluge-${DELUGE_VERSION}.tar.gz | tar xz && \
  cd \
   deluge-${DELUGE_VERSION}/ && \
  python setup.py -q build && \
  python setup.py -q install && \
#Cleanup and chmod for entrypoint and pwgen script.
  rm -rf \
   /usr/lib/python2.7/site-packages/deluge-${DELUGE_VERSION}-py2.7.egg/share/* \
   /usr/lib/python2.7/site-packages/deluge-${DELUGE_VERSION}-py2.7.egg/deluge/data/pixmaps/* \
   /usr/lib/python2.7/site-packages/deluge-${DELUGE_VERSION}-py2.7.egg/deluge/ui/gtkui/* \
   /usr/lib/python2.7/site-packages/deluge-${DELUGE_VERSION}-py2.7.egg/deluge/ui/i18n/* \
   /usr/lib/python2.7/site-packages/deluge-${DELUGE_VERSION}-py2.7.egg/deluge/ui/web/* \
   /usr/bin/deluge /usr/bin/deluge-web /usr/bin/deluge-gtk && \
  apk del .build_deluge && \
  cd /root && \
  rm -rf \
   /root/* && \
  chmod +x \
   /usr/bin/deluged-pass.sh \
   /usr/bin/docker-entrypoint.sh

WORKDIR \
 ${D_DIR}/config

 RUN \
#Deluged first run
  /usr/bin/deluged \
   -c ${D_DIR}/config \
   -l ${D_DIR}/config/first_init.log \
   -L debug && \
  sleep 10 && \
#Deluged configuration
  deluge-console \
   -c ${D_DIR}/config "config" && \
  deluge-console \
   -c ${D_DIR}/config "config -s allow_remote true" && \
  deluge-console \
   -c ${D_DIR}/config "config -s move_completed_path ${D_DIR}/complete" && \
  deluge-console \
   -c ${D_DIR}/config "config -s download_location ${D_DIR}/downloads" && \
  deluge-console \
   -c ${D_DIR}/config "config -s daemon_port ${D_D_PORT}" && \
  deluge-console \
   -c ${D_DIR}/config "config -s random_port false" && \
  deluge-console \
   -c ${D_DIR}/config "config -s listen_ports (${D_D_INCOMING_PORT},${D_D_INCOMING_PORT})" && \
  deluge-console \
   -c ${D_DIR}/config "halt" && \
  chown -R \
   ${D_USER}:${D_GROUP} \
   ${D_DIR}

EXPOSE \
 ${D_D_PORT} \
 ${D_D_INCOMING_PORT} \
 ${D_D_INCOMING_PORT}/udp

ENTRYPOINT \
 ["/usr/bin/docker-entrypoint.sh"]

LABEL \
 net.sinaptika.maintainer="info@sinaptika.net" \
 net.sinaptika.name="deluged" \
 net.sinaptika.branch="dev" \
 net.sinaptika.from="alpine:3.6" \
 c_software_name="Deluge Daemon" \
 c_software_url="http://deluge-torrent.org/" \
 image.version="0.2" \
 date.version="1.8.2017" \
 web_interface="true" \
 web_interface_port=${D_D_PORT} \
 exposed_ports=${D_D_PORT},${D_D_INCOMING_PORT},${D_D_INCOMING_PORT}/udp  \
 docker_volumes=${D_DIR}
