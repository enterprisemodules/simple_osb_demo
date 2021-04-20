# Demo Puppet Fusion OSB implementation

**Work In Progress**

This repo contains a demonstration of an Fusion Middleware OSB installation. It's purpose is to help you guide through an initial installation of an Oracle WebLogic node with Puppet. This demo is ready for Puppet 4 and for Puppet 5.

## Starting the nodes masterless

All nodes are available to test with Puppet masterless. To do so, add `ml-` for the name when using vagrant:

```
$ vagrant up ml-osb12213n1
```

## Staring the nodes with PE

You can also test with a Puppet Enterprise server. To do so, add `pe-` for the name when using vagrant:

```
$ vagrant up pe-wlsmaster
$ vagrant up pe-osb12213n1
$ vagrant up pe-osb12213n2
$ vagrant up pe-osb12214n1
$ vagrant up pe-osb12214n2
```

## ordering

You must always use the specified order:

1. wlsmaster
2. osb12213n1
3. osb12213n2
4. osb12214n1
5. osb12214n2

## Required software

The software must be placed in `modules/software/files`. It must contain the next files:

### Puppet Enterprise
- puppet-enterprise-2017.2.3-el-7-x86_64-x86_64.tar.gz (Extracted tar)

### Oracle WebLogic 12.2.1.3 (for machines osb12213n1, osb12213n2)
- fmw_12.2.1.3.0_infrastructure.jar
- fmw_12.2.1.3.0_osb.jar.zip

### Oracle WebLogic 12.2.1.4 (for machines osb12214n1, osb12214n2)
- fmw_12.2.1.4.0_infrastructure.jar
- fmw_12.2.1.4.0_osb.jar.zip

### Java
- jdk-8u161-linux-x64.tar.gz
- jce_policy-8.zip

You can download this file from
[here](http://support.oracle.com)
