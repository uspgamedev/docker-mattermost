FROM debian

ENV MM_VERSION=4.10.0

RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        netcat \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /mattermost/data \
    && curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz | tar -xvz\
    && cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json

ARG PUID=2000
ARG PGID=2000

RUN set -x; \
    addgroup --gid ${PGID} mattermost \
    && adduser --system --uid ${PUID} --gid ${PGID} --home /mattermost mattermost \
    && chown -R mattermost:mattermost /mattermost /config.json.save 

USER mattermost

HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["platform"]

EXPOSE 8000
ENV PATH="/mattermost/bin:${PATH}"

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config"]
