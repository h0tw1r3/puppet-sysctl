sysctl::configure { 'net.ipv4.ip_forward': ensure => '1' }
sysctl::configure { 'net.core.somaxconn': ensure => '65536' }
sysctl::configure { 'vm.swappiness': ensure => absent }
sysctl::configure { 'net.ipv4.conf.eth0/1.forwarding': ensure => 1 }
sysctl::configure { 'kernel.domainname': ensure => "foobar.'backquote.com" }
sysctl::configure { 'kernel.core_pattern':
  ensure  => '|/scripts/core-gzip.sh /var/tmp/core/core.%e.%p.%h.%t.gz',
  comment => 'wrapper script to gzip core dumps',
}
