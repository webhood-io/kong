# When you update this file substantially, please update build_your_own_images.md as well.
FROM debian:bullseye-20230227-slim

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG KONG_VERSION=3.2.2
ENV KONG_VERSION $KONG_VERSION

ARG KONG_SHA256="772676b0cf27c063642a953a81e6025f511c9aa4427cbca60c956a31f438ef6f"

ARG KONG_PREFIX=/usr/local/kong
ENV KONG_PREFIX $KONG_PREFIX

ARG ASSET=remote
ARG EE_PORTS

# COPY kong.deb /tmp/kong.deb

RUN set -ex; \
    apt-get update; \
    apt-get install -y curl; \
    if [ "$ASSET" = "remote" ] ; then \
      CODENAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d = -f 2) \
      && DOWNLOAD_URL="https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-debian-${CODENAME}/pool/all/k/kong/kong_${KONG_VERSION}_amd64.deb" \
      && curl -fL $DOWNLOAD_URL -o /tmp/kong.deb \
      && echo "$KONG_SHA256  /tmp/kong.deb" | sha256sum -c -; \
    fi \
    && apt-get update \
    && apt-get install --yes /tmp/kong.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/kong.deb \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 ${KONG_PREFIX} \
    && ln -sf /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && kong version \
    && apt-get purge curl -y

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong-health

CMD ["kong", "docker-start"]