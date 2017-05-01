#Maintainer info@sinaptika.net
#deluge http://deluge-torrent.org/
#deluged image
FROM alpine:3.5

ENV \
	DELUGE_VERSION=1.3.14 \
	D_DIR=/opt/deluge \
	TZ=Europe/London \
	D_UID=1000 \
	D_GID=1000 \
	D_USER=deluge \
	D_GROUP=deluge \
	D_LOG_LEVEL=warn \
	DELUGED_DAEMON_PORT=58846 \
	DELUGED_INCOMING_PORT=50100

RUN \
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
	apk add --no-cache \
		--repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
		--repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
		--repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
			su-exec tzdata tini pwgen \
			openssl boost zlib unrar geoip \
			py-setuptools py2-pip py2-openssl py2-chardet py-xdg py2-geoip py-twisted \
			libtorrent-rasterbar && \
	pip install --no-cache-dir \
		service_identity \
		incremental \
		constantly \
		packaging && \
	wget -q \
		http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz -O \
		/tmp/GeoIP.dat.gz && gunzip /tmp/GeoIP.dat.gz && \
	mv \
		/tmp/GeoIP.dat /usr/share/GeoIP && \
	cd /root && \
	wget -qO- \
		http://download.deluge-torrent.org/source/deluge-${DELUGE_VERSION}.tar.gz | tar xz && \
	cd \
		deluge-${DELUGE_VERSION}/ && \
	python setup.py -q build && \
	python setup.py -q install && \
	rm -rf \
		/usr/lib/python2.7/site-packages/deluge-1.3.14-py2.7.egg/share/icons/* \
		/usr/lib/python2.7/site-packages/deluge-1.3.14-py2.7.egg/share/pixmaps/* \
		/usr/lib/python2.7/site-packages/deluge-1.3.14-py2.7.egg/deluge/data/pixmaps/* \
		/usr/lib/python2.7/site-packages/deluge-1.3.14-py2.7.egg/deluge/ui/gtkui/* \
		/usr/lib/python2.7/site-packages/deluge-1.3.14-py2.7.egg/deluge/ui/web/* \
		/usr/bin/deluge /usr/bin/deluge-web /usr/bin/deluge-gtk && \
	apk del \
		geoip \
		openssl \
		boost \
		py2-pip && \
	rm -rf \
		/root/*. && \
	chmod +x \
		/usr/bin/deluged-pass.sh \
		/usr/bin/docker-entrypoint.sh

WORKDIR \
	${D_DIR}

RUN \
	/usr/bin/deluged \
		-c ${D_DIR}/config \
		-l ${D_DIR}/config/first_init.log \
		-L debug && \
	sleep 10 && \
	deluge-console \
		-c ${D_DIR}/config \
			"config" && \
	deluge-console \
		-c ${D_DIR}/config \
			"config -s allow_remote true" && \
	deluge-console \
		-c ${D_DIR}/config \
			"config -s move_completed_path ${D_DIR}/complete" && \
	deluge-console \
		-c ${D_DIR}/config \
			"config -s download_location ${D_DIR}/downloads" && \
	deluge-console \
		-c ${D_DIR}/config \
			"config -s daemon_port ${DELUGED_DAEMON_PORT}" && \
	deluge-console \
		-c ${D_DIR}/config \
			"config -s random_port false" && \
	deluge-console \
		-c ${D_DIR}/config \
			"config -s listen_ports (${DELUGED_INCOMING_PORT},${DELUGED_INCOMING_PORT})" && \
	deluge-console \
		-c ${D_DIR}/config \
			"halt" && \
	chown -R \
		${D_USER}:${D_GROUP} \
		${D_DIR}

EXPOSE \
	${DELUGED_DAEMON_PORT} \
	${DELUGED_INCOMING_PORT} \
	${DELUGED_INCOMING_PORT}/udp

ENTRYPOINT \
	["/usr/bin/docker-entrypoint.sh"]

LABEL \
	net.sinaptika.maintainer="info@sinaptika.net" \
	net.sinaptika.name="hs-deluged" \
	net.sinaptika.branch="testing" \
	net.sinaptika.from="alpine:3.5" \
	c_software_name="Deluge Daemon" \
	c_software_url="http://deluge-torrent.org/" \
	image.version="0.9" \
	date.version="1.5.2017" \
	web_interface=true \
	web_interface_port=${DELUGED_DAEMON_PORT} \
	exposed_ports=${DELUGED_INCOMING_PORT},${DELUGED_DAEMON_PORT} \
	docker_volumes=${D_DIR}
