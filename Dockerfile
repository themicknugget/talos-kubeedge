# KubeEdge EdgeCore Extension for Talos 1.12

ARG EDGE_CORE_VERSION=v1.22.1
ARG TARGETPLATFORM

FROM alpine:3.20 AS builder

RUN apk add --no-cache curl tar

ARG EDGE_CORE_VERSION
ARG TARGETPLATFORM
RUN ARCH=$(echo "${TARGETPLATFORM}" | sed 's|linux/||' | sed 's|amd64|amd64|' | sed 's|arm64|arm64|'); \
    curl -L "https://github.com/kubeedge/kubeedge/releases/download/${EDGE_CORE_VERSION}/kubeedge-${EDGE_CORE_VERSION}-linux-${ARCH}.tar.gz" \
    -o /tmp/edgecore.tar.gz && \
    tar -xzf /tmp/edgecore.tar.gz -C /tmp/

FROM scratch

COPY --from=builder /tmp/kubeedge-*/edge/edgecore /rootfs/usr/local/lib/containers/edgecore/edgecore
COPY extension-edgecore.service /rootfs/usr/local/lib/systemd/system/extension-edgecore.service
COPY manifest.yaml /

LABEL org.opencontainers.image.title="KubeEdge EdgeCore Extension"
LABEL org.opencontainers.image.description="Talos 1.12 extension service for KubeEdge EdgeCore"
