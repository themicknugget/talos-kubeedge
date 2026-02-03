#!/bin/sh
# KubeEdge EdgeCore startup script
# Sets up CNI configuration for edge node before starting edgecore

set -e

# Copy bridge CNI config to host /etc/cni/net.d/ (takes precedence with 00- prefix)
if [ -f /var/etc/cni/net.d/00-edge-bridge.conflist ]; then
    echo "Copying bridge CNI config to /etc/cni/net.d/"
    cp /var/etc/cni/net.d/00-edge-bridge.conflist /etc/cni/net.d/00-edge-bridge.conflist 2>/dev/null || true
fi

# Remove Cilium CNI config if it exists (not needed on edge nodes)
if [ -f /etc/cni/net.d/05-cilium.conflist ]; then
    echo "Removing Cilium CNI config (not used on edge nodes)"
    rm -f /etc/cni/net.d/05-cilium.conflist 2>/dev/null || true
fi

echo "Starting edgecore..."
exec /edgecore "$@"
