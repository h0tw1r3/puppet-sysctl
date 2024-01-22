include sysctl

# Manage a parameter with a resource:
sysctl::variable { 'net.ipv4.ip_forward':
  ensure => '1',
}

# Separate multi-value variables with a single space:
sysctl::variable { 'net.ipv4.tcp_rmem':
  ensure => '4096 65536 16777216',
}

# Remove the sysctl configuration for a variable:
sysctl::variable { 'vm.swappiness':
  ensure => absent,
}

# Ensure variables are set in a consistent order using the prefix parameter
# overrides previously declared net.ipv4.ip_forward by using a different title
sysctl::variable { 'prefix-net-ipv4-ip_forward':
  variable => 'net.ipv4.ip_forward',
  ensure   => '1',
  prefix   => '60',
}
