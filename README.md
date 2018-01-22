# Demo Puppet Fusion OSB implementation

**Work In Progress**

This repo contains a demonstration of an Fusion Middleware OSB installation. It's purpose is to help you guide through an initial installation of an Oracle WebLogic node with Puppet. This demo is ready for Puppet 4 and for Puppet 5.

## Starting the nodes masterless

All nodes are available to test with Puppet masterless. To do so, add `ml-` for the name when using vagrant:

```
$ vagrant up ml-osb1
```

## Staring the nodes with PE

You can also test with a Puppet Enterprise server. To do so, add `pe-` for the name when using vagrant:

```
$ vagrant up pe-wlsmaster
$ vagrant up pe-osb1
```

## ordering

You must always use the specified order:

1. wlmaster
2. osb1
2. osb2

## Required software

The software must be placed in `modules/software/files`. It must contain the next files:

### Puppet Enterprise
- puppet-enterprise-2017.2.3-el-7-x86_64-x86_64.tar.gz (Extracted tar)

### Oracle WebLogic 12.2.1.2
- fmw_12.2.1.2.0_infrastructure.jar
- fmw_12.2.1.2.0_osb.jar.zip

### Java
- jdk-8u141-linux-x64.tar.gz
- jce_policy-8.zip

You can download this file from
[here](http://support.oracle.com)
