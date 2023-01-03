# @summary
#
# @param variable
#   hash of variables to set, typically defined in hiera
# @param purge
#   purge conf_dir of any non-puppet managed files
# @param symlink99
#   symlink sysctl.conf to conf_dir/99-sysctl.conf
# @param binary
#   full path of sysctl executable
# @param use_dir
#   manage per-variable files in conf_dir
# @param conf_dir
#   full path to sysctl conf.d directory
# @param owner
#   set file owner
# @param group
#   set file group
# @param mode
#   set file mode
#
# @example
#   include sysctl
class sysctl (
  Variant[Hash,Undef]           $variable,
  Boolean                       $purge,
  Boolean                       $symlink99,
  Stdlib::Absolutepath          $binary,
  Boolean                       $use_dir,
  Stdlib::Absolutepath          $conf_dir,
  Variant[String,Integer,Undef] $owner,
  Variant[String,Integer,Undef] $group,
  Variant[String,Undef]         $mode
) {
  $variable.each |String $val, Hash $params| {
    sysctl::variable { $val:
      * => $params,
    }
  }

  if $use_dir {
    # if we're purging we should also recurse
    $recurse = $purge
    file { $conf_dir:
      ensure  => directory,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      purge   => $purge,
      recurse => $recurse,
    }

    if $symlink99 and $conf_dir =~ /^\/etc\/[^\/]+$/ {
      file { "${conf_dir}/99-sysctl.conf":
        ensure => link,
        target => '../sysctl.conf',
      }
    }
  }

  Sysctl::Define <||>
}
