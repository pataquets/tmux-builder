## -*- dockerfile-image-name: "tmux-builder" -*-
ARG BASE_IMAGE="ubuntu:jammy"
FROM ${BASE_IMAGE} AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN \
  apt-get update && \
  apt-get install -y \
    autoconf \
    bison \
    build-essential \
    git \
    libevent-dev \
    libncurses-dev \
    pkg-config \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/

RUN mkdir --verbose --parents /usr/src/tmux/
WORKDIR /usr/src/tmux/

ARG GIT_BRANCH
RUN git clone --depth 1 --branch ${GIT_BRANCH:-master} https://github.com/tmux/tmux .

RUN ./autogen.sh
RUN ./configure --enable-static
RUN make

FROM scratch AS export-stage

COPY --from=builder /usr/src/tmux/tmux .
COPY --from=builder /usr/src/tmux/tmux.1 .
