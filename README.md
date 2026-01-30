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

## Compatibility

| Talos Version |
|---------------|
| v1.12.x |

## License

Apache 2.0
