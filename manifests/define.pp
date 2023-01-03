# @summary collected resource to manage a variable
#
# @api private
#
define sysctl::define (
  String $variable          = $title,
  Optional[String] $ensure  = undef,
  Optional[String] $prefix  = undef,
  String $suffix            = '.conf',
  Optional[String] $content = undef,
  Optional[String] $source  = undef,
  Boolean $enforce          = true,
  Optional[Variant[String,Array[String]]] $comment = undef,
) {
  $conf_ensure = ($ensure =~ Undef or $ensure == 'absent') ? {
    true  => 'absent',
    false => 'present',
  }

  $_sysctl_d_file = $prefix ? {
    true    => "${prefix}-${variable}${suffix}",
    default => "${variable}${suffix}",
  }

  $sysctl_d_file = regsubst($_sysctl_d_file, '[/ ]', '_', 'G')

  $file_content = ($content !~ Undef) ? {
    true  => $content,
    false => epp("${module_name}/sysctl_conf.epp", {
        comment  => ($comment =~ Array or $comment =~ Undef) ? {
          true  => $comment,
          false => [$comment],
        },
        variable => $variable,
        value    => $ensure,
      }
    )
  }

  $file_source = ($source !~ Undef) ? {
    true  => $source,
    false => undef,
  }

  if $conf_ensure == 'absent' {
    file { "${sysctl::conf_dir}/${sysctl_d_file}":
      ensure => absent,
    }
  } else {
    if $enforce and !($content and $source) {
      $q_variable = shellquote($variable)
      $q_value = shellquote($ensure)
      exec { "sysctl-enforce-${variable}":
        command => sprintf('%s -w %s=%s', $sysctl::binary, $q_variable, $q_value),
        path    => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        unless  => sprintf('%s -n %s | tr "\t" " " | grep -q ^%s\$', $sysctl::binary, $q_variable, $q_value),
      }

      $before = Exec["sysctl-enforce-${variable}"]
    }

    if $sysctl::use_dir {
      file { "${sysctl::conf_dir}/${sysctl_d_file}":
        ensure       => $conf_ensure,
        owner        => $sysctl::owner,
        group        => $sysctl::group,
        mode         => '0644',
        content      => $file_content,
        source       => $file_source,
        validate_cmd => "${sysctl::binary} -p %",
        before       => $before,
      }
    } else {
      file_line { "sysctl-add-${variable}":
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => "${variable} = ${ensure}",
        match  => "^${variable} *= *${ensure}",
      }
    }
  }

  if $conf_ensure == 'absent' or $sysctl::use_dir {
    file_line { "sysctl-remove-${variable}":
      ensure            => absent,
      path              => '/etc/sysctl.conf',
      match             => "^[# ]*${variable} *=",
      match_for_absence => true,
      multiple          => true,
      require           => File["${sysctl::conf_dir}/${sysctl_d_file}"],
    }
  }
}
