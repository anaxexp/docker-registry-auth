ARG AUTH_SERVER_VER

FROM cesanta/docker_auth:${AUTH_SERVER_VER} as build

FROM anaxexp/alpine:3.7-2.0.1

ENV GOTPL_VER="0.1.5" \
    DOCKER_AUTH_CONF_DIR="/etc/docker_auth" \
    DOCKER_AUTH_CERTS_DIR="/etc/docker_auth/certs"

RUN set -xe; \
    \
    apk add --update --no-cache -t .run-deps \
        apache2-utils \
        curl \
        jq \
        libressl \
        make \
        pwgen; \
    \
    gotpl_url="https://github.com/anaxexp/gotpl/releases/download/${GOTPL_VER}/gotpl-alpine-linux-amd64-${GOTPL_VER}.tar.gz"; \
    wget -qO- "${gotpl_url}" | tar xz -C /usr/local/bin; \
    \
    mkdir -p "${DOCKER_AUTH_CONF_DIR}" "${DOCKER_AUTH_CERTS_DIR}"

COPY --from=build /docker_auth/auth_server /usr/local/bin/auth_server

COPY templates /etc/gotpl/
COPY bin /usr/local/bin
COPY entrypoint.sh /

WORKDIR "${DOCKER_AUTH_CONF_DIR}"

EXPOSE 5001

ENTRYPOINT ["/entrypoint.sh"]

CMD ["auth_server", "--v=3", "--alsologtostderr", "/etc/docker_auth/config.yml"]