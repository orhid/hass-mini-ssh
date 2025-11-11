ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG LIBWEBSOCKETS_VERSION
ARG TTYD_VERSION
RUN \
    set -x \ 
    && apk add --no-cache \
        bluez \
        git \
        libuv \
        mosquitto-clients \
        openssh \
        pwgen \
        stow \
        zellij \
    \
    && apk add --no-cache --virtual .build-dependencies \
        bsd-compat-headers \
        build-base \
        linux-headers \
        cmake \
        json-c-dev \
        libuv-dev \
        openssl-dev \
        zlib-dev \
    \
    && git clone --branch "v${LIBWEBSOCKETS_VERSION}" --depth=1 \
        https://github.com/warmcat/libwebsockets.git /tmp/libwebsockets \
    \
    && mkdir -p /tmp/libwebsockets/build \
    && cd /tmp/libwebsockets/build \
    && cmake .. \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_VERBOSE_MAKEFILE=TRUE \
        -DLWS_IPV6=ON \
        -DLWS_STATIC_PIC=ON \
        -DLWS_UNIX_SOCK=ON \
        -DLWS_WITH_LIBUV=ON \
        -DLWS_WITH_SHARED=ON \
        -DLWS_WITHOUT_TESTAPPS=ON \
    && make \
    && make install \
    \
    && git clone --branch main --single-branch \
        https://github.com/tsl0922/ttyd.git /tmp/ttyd \
    && git -C /tmp/ttyd checkout "${TTYD_VERSION}" \
    \
    && mkdir -p /tmp/ttyd/build \
    && cd /tmp/ttyd/build \
    && cmake .. \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    && make \
    && make install \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -f -r \
        /root/.cache \
        /root/.cmake \
        /tmp/*

# Home Assistant CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN curl -Lso /usr/bin/ha \
        "https://github.com/home-assistant/cli/releases/download/${CLI_VERSION}/ha_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/ha

# Copy data
COPY rootfs /

# orh dotfiles
RUN cd / \
    && git clone https://github.com/orhid/kropki .kropki \
    && cd .kropki \
    && stow ash/ \
    && stow bottom/ \
    && stow git/ \
    && stow helix/

RUN hostname husrathandi
