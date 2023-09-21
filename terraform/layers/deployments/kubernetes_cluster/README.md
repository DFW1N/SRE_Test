## Virtual Machine Deployment

This directory will contain the models required to build a kubernetes cluster that hosts a auto scaling web server.

### What this Deployment Does

This deployment deploys the following resources

```bash
1. resource group
2. kubernetes_cluster
```

It will automatically deploy everything in sequence and is easily customizable using the `config/` directory.

It pulls a nginx image from docker hub. It makes it available online.