# Kubernetes Cluster Deployment

This directory will contain the models required to build a azure kubernetes cluster that pulls a container with hello world on it.



### What this Deployment Does

This deployment deploys the following resources

```bash
1 resource group
1 virtual network
3 subnets
3 network security groups
2 network rules to allow http and https

```

It will automatically deploy everything in sequence and is easily customizable using the `config/` directory.

It also pulls a hello world container.