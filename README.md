# KubeEdge EdgeCore Extension for Talos Linux

A Talos Linux extension service that provides [KubeEdge EdgeCore](https://kubeedge.io) for cloud-native edge computing.

## Quick Start

### 1. Extension Image

Published to:
```
ghcr.io/themicknugget/talos-kubeedge:latest
```

### 2. Build Talos Installer with Extension

Since this is a third-party extension, you cannot use Talos Image Factory. Use `talosctl imager` instead:

```bash
talosctl imager \
  --talos-version=v1.12.5 \
  --system-extension-image=ghcr.io/themicknugget/talos-kubeedge:latest \
  --output-installer installer.tar.gz
```

Then load and push to your registry:
```bash
docker load -i installer.tar.gz
docker tag <image-sha> <your-registry>/talos-kubeedge-installer:v1.12.5-kubeedge
docker push <your-registry>/talos-kubeedge-installer:v1.12.5-kubeedge
```

### 3. Deploy

Use your custom installer in machine config:
```yaml
machine:
  install:
    image: <your-registry>/talos-kubeedge-installer:v1.12.5-kubeedge
```

## Configuration

> **Note:** Talos Linux has an immutable root filesystem. Configuration files must be stored in `/var` to be writable via machine config. This extension uses `/var/lib/kubeedge` for all configuration and data files.

Configure EdgeCore via `ExtensionServiceConfig`:

```yaml
apiVersion: v1alpha1
kind: ExtensionServiceConfig
metadata:
  name: edgecore
spec:
  configFiles:
    - content: |
        apiVersion: edgecore.config.kubeedge.io/v1alpha2
        kind: EdgeCore
        modules:
          edged:
            nodeName: edge-node-1
          edgehub:
            websocket:
              server: <cloudcore-server>
              port: 10000
      mountPath: /var/lib/kubeedge/config/edgecore.yaml
      permissions: 0600

  environment:
    - name: EDGE_CLOUDCORE_SERVER
      value: "<cloudcore-server>:10000"
```

## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds the extension OCI image |
| `manifest.yaml` | Extension metadata (required for Talos) |
| `edgecore.yaml` | Talos native extension service configuration |
| `extension-edgecore.service` | Systemd service file (kept for reference, not used in Talos) |
| `machineconfig.yaml` | Example Talos configuration |

## Extension Service Format

This extension uses Talos v1.12's native extension service format (YAML configuration files in `/usr/local/etc/containers/*.yaml`) instead of systemd. Talos Linux does not use systemd for managing extension services.

The `edgecore.yaml` file defines:
- Container entrypoint and arguments
- Environment variables
- Volume mounts for persistent data
- Service dependencies (network, CRI, configuration)
- Restart policy

This approach aligns with Talos's container-first architecture and provides better integration with the Talos extension framework.

## Compatibility

| Talos Version |
|---------------|
| v1.12.x |

## License

Apache 2.0
