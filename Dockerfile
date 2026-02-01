# KubeEdge EdgeCore Extension for Talos 1.12
# Builds edgecore statically from source to work with Talos's musl libc

ARG EDGE_CORE_VERSION=v1.22.1

FROM alpine:3.20 AS builder

RUN apk add --no-cache \
    git \
    go \
    make \
    gcc \
    musl-dev \
    linux-headers \
    bash

ARG EDGE_CORE_VERSION
RUN git clone --depth 1 --branch ${EDGE_CORE_VERSION} https://github.com/kubeedge/kubeedge /src
WORKDIR /src

# Build edgecore statically
RUN CGO_ENABLED=0 make all WHAT=edgecore BUILD_WITH_CONTAINER=false
RUN ls -la _output/local/bin/edgecore && cp _output/local/bin/edgecore /edgecore && ls -la /edgecore

FROM scratch

COPY --from=builder /src/edgecore /rootfs/usr/local/lib/containers/edgecore/edgecore

# Talos v1.12 uses native extension services (YAML config) instead of systemd
# The extension-edgecore.service file is not used in Talos and is kept for reference only
# COPY extension-edgecore.service /rootfs/usr/local/lib/systemd/system/extension-edgecore.service

COPY edgecore.yaml /rootfs/usr/local/etc/containers/edgecore.yaml
COPY manifest.yaml /

LABEL org.opencontainers.image.title="KubeEdge EdgeCore Extension (Static)"
LABEL org.opencontainers.image.description="Talos 1.12 extension service for KubeEdge EdgeCore - statically linked"
