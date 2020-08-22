# ffmpegfs in Docker

FROM jrottenberg/ffmpeg:vaapi AS base

WORKDIR     /tmp/workdir

RUN     apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates expat libgomp1 && \
        apt-get autoremove -y && \
        apt-get clean -y

FROM base as build

RUN      buildDeps="g++ \
                    gcc \
                    make \
                    pkg-config \
                    asciidoc-base \
                    w3m \
                    fuse \
                    libfuse-dev \
                    libsqlite3-dev \
                    curl \
                    libchromaprint-dev \
                    bc" && \
        apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ${buildDeps}

ENV         FFMPEGFS_VERSION=1.99 \
            PKG_CONFIG_PATH=/usr/local/lib

RUN     curl -sLO https://github.com/nschlia/ffmpegfs/releases/download/v1.99/ffmpegfs-${FFMPEGFS_VERSION}.tar.gz && \
        tar xvfz "ffmpegfs-${FFMPEGFS_VERSION}.tar.gz" && \
        cd ffmpegfs-1.99 && \
        ./configure && \
        make && \
        make install

FROM build AS test

RUN     make checks

FROM build AS release
MAINTAINER  Jessica Stokes <hello@jessicastokes.net>

CMD         ["--help"]
ENTRYPOINT  ["ffmpegfs"]

COPY --from=build /usr/local /usr/local/

RUN     rm -rf /var/lib/apt/lists/*
