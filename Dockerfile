FROM alpine:latest

RUN apk add --update --no-cache \
	glib libpurple gnutls libgcrypt
RUN apk add --no-cache --virtual build-dependencies \
	glib-dev pidgin-dev curl jq gcc g++ gnutls-dev make libgcrypt-dev
RUN BITLBEE_TARBALL="$(curl -sS https://api.github.com/repos/bitlbee/bitlbee/releases/latest | jq .tarball_url -r)" \
	&& curl -sSL $BITLBEE_TARBALL -o /tmp/bitlbee.tar.gz \
	&& mkdir /tmp/bitlbee \
	&& tar xzf /tmp/bitlbee.tar.gz --strip 1 -C /tmp/bitlbee \
	&& cd /tmp/bitlbee \
	&& ./configure --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl --purple=1 --ssl=gnutls --prefix=/usr --etcdir=/etc/bitlbee \
	&& make \
	&& make install \
	&& make install-dev

RUN apk add --no-cache --virtual build-dependencies \
	autoconf automake libtool git
RUN git clone https://github.com/jgeboski/bitlbee-steam.git /tmp/bitlbee-steam \
	&& cd /tmp/bitlbee-steam \
	&& ./autogen.sh --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl \
	&& make \
	&& make install \
	&& strip /usr/lib/bitlbee/steam.so

RUN git clone https://github.com/sm00th/bitlbee-discord.git /tmp/bitlbee-discord \
	&& cd /tmp/bitlbee-discord \
	&& ./autogen.sh --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl \
	&& ./configure --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl \
	&& make \
	&& make install \
	&& strip /usr/lib/bitlbee/discord.so

RUN apk add --update --no-cache \
	json-glib
RUN apk add --no-cache --virtual build-dependencies \
	json-glib-dev
RUN git clone git://github.com/EionRobb/skype4pidgin.git /tmp/skype4pidgin \
	&& cd /tmp/skype4pidgin/skypeweb \
	&& make \
	&& make install \
	&& strip /usr/lib/purple-2/libskypeweb.so

RUN apk add --update --no-cache \
	libwebp
RUN apk add --no-cache --virtual build-dependencies \
	libwebp-dev
RUN git clone --recursive https://github.com/majn/telegram-purple /tmp/telegram-purple \
	&& cd /tmp/telegram-purple \
	&& ./configure --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl \
	&& make \
	&& make install \
	&& strip /usr/lib/purple-2/telegram-purple.so

RUN apk del build-dependencies \
	&& rm -rf /tmp/* \
	&& rm -rf /usr/include/bitlbee \
	&& rm -f /usr/lib/pkgconfig/bitlbee.pc

COPY entrypoint.sh /usr/local/bin/

ENV UID=1496
ENV GID=1496

RUN addgroup -g "$GID" -S bitlbee \
	&& adduser -u "$UID" -D -S -h /var/lib/bitlbee -s /bin/sh -G bitlbee bitlbee \
	&& chown bitlbee:bitlbee /var/lib/bitlbee

VOLUME /var/lib/bitlbee

EXPOSE 6667

ENTRYPOINT [ "entrypoint.sh" ]
