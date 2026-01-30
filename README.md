# KubeEdge EdgeCore Extension for Talos Linux

A Talos Linux extension service that provides [KubeEdge EdgeCore](https://kubeedge.io) for cloud-native edge computing.

## Quick Start

### 1. Use the Extension Image

Images are built automatically by GitHub Actions:
```
ghcr.io/themicknugget/talos-kubeedge:latest
```

### 2. Create Talos Installer with Extension

Visit [Talos Image Factory](https://factory.talos.dev/), add the extension image, and generate a custom installer.

Or use `talosctl imager`:
```bash
talosctl imager \
  --system-extension-image=ghcr.io/themicknugget/talos-kubeedge:latest \
  --output-installer installer.tar.gz
```

### 3. Deploy

Update your Talos machine config:
```yaml
machine:
  install:
    image: <your-installer-from-image-factory>
```

Apply:
```bash
talosctl apply-config --insecure --nodes <node-ip> --file machineconfig.yaml
```

## Configuration

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
      mountPath: /etc/kubeedge/config/edgecore.yaml
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
| `extension-edgecore.service` | Systemd service that runs EdgeCore |
| `machineconfig.yaml` | Example Talos configuration |
| `.github/workflows/build-extension.yml` | GitHub Actions CI/CD |

## Compatibility

| Talos Version |
|---------------|
| v1.12.x |

## License

Apache 2.0
