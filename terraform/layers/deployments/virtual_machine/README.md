## Virtual Machine Deployment

This directory will contain the models required to build a virtual machine that hosts a auto scaling web server.

### What this Deployment Does

This deployment deploys the following resources

```bash
1 resource group
1 virtual network
3 subnets
3 network security groups
2 network rules to allow http and https
1 public ip address
1 network interface
1 ubuntu linux virtual machine
```

It will automatically deploy everything in sequence and is easily customizable using the `config/` directory.

It also sets up a hello world virtual machine that will autoscale.