# KubeEdge EdgeCore Extension for Talos 1.12
# Builds edgecore statically from source to work with Talos's musl libc

ARG EDGE_CORE_VERSION=v1.22.1
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

FROM alpine:3.20 AS builder

RUN apk add --no-cache \
    git \
    go \
    make \
    gcc \
    musl-dev \
    sqlite-dev \
    sqlite-libs \
    linux-headers \
    bash

ARG EDGE_CORE_VERSION
RUN git clone --depth 1 --branch ${EDGE_CORE_VERSION} https://github.com/kubeedge/kubeedge /src
WORKDIR /src

# Build edgecore with CGO for sqlite support, statically linked with musl
# Use the target architecture from the build platform
RUN CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    make all WHAT=edgecore BUILD_WITH_CONTAINER=false \
    LDFLAGS="-linkmode external -extldflags '-static'"

FROM scratch

COPY --from=builder /src/_output/local/bin/edgecore /rootfs/edgecore

# Talos v1.12 uses native extension services (YAML config) instead of systemd
# The extension-edgecore.service file is not used in Talos and is kept for reference only
# COPY extension-edgecore.service /rootfs/usr/local/lib/systemd/system/extension-edgecore.service

COPY edgecore.yaml /rootfs/usr/local/etc/containers/edgecore.yaml
COPY manifest.yaml /

LABEL org.opencontainers.image.title="KubeEdge EdgeCore Extension (Static)"
LABEL org.opencontainers.image.description="Talos 1.12 extension service for KubeEdge EdgeCore - statically linked"
