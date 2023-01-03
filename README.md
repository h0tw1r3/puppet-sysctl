# sysctl

## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
    * [What sysctl affects](#what-sysctl-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sysctl](#beginning-with-sysctl)
1. [Usage](#usage)
1. [Limitations](#limitations)

## Description

[sysctl] is used to modify kernel parameters at runtime. The parameters
available on Linux are those listed under `/proc/sys/`. Procfs is required for
sysctl support in Linux.

This module supports setting parameter values that are persistent across
reboots by managing the system [sysctl] configuration files.

`sysctl::variable` resource declares the "private" resource, `sysctl::define`,
which is exported and eventually collected by the `sysctl` class.

## Setup

### What sysctl affects

* /etc/sysctl.conf
* /etc/sysctl.d/\*.conf
* optionally execute sysctl at runtime to enforce values

### Beginning with sysctl

To make use of the `sysctl::variable` resource, the `sysctl` class must be
included in your puppet manifest.

```puppet
include sysctl
```

## Usage

Manage a parameter with a resource:
```puppet
sysctl::variable { 'net.ipv4.ip_forward':
  ensure => '1',
}
```

Manage multiple parameters with hiera:
```yaml
sysctl::variable:
  net.ipv4.ip_forward:
    ensure: 1
  net.ipv6.bindv6only:
    ensure: 1
    enforce: false
  net.ipv4.tcp_congestion_control:
    ensure: absent
  net.core.somaxconn:
    ensure: 65535
    comment: increased to accommodate traffic handling requirements
```

Separate multi-value variables with a single space:
```puppet
sysctl::variable { 'net.ipv4.tcp_rmem':
  ensure => '4096 65536 16777216',
}
```

Remove the sysctl configuration for a variable:
```puppet
sysctl::variable { 'vm.swappiness':
  ensure => absent,
}
```

Ensure variables are set in a consistent order using the prefix parameter:
```puppet
sysctl::variable { 'net.ipv4.ip_forward':
  ensure => '1',
  prefix => '60',
}
```
## Limitations

Testing! Could use many more unit tests.

## Credit

Inspired by Matthias Saou's [thias/puppet-sysctl] module.

[thias/puppet-sysctl]: https://github.com/thias/puppet-sysctl
