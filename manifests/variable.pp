# @summary manage a kernel variable with sysctl
#
# @param variable
#   kernel variable to manage, defaults to the resource title
# @param ensure
#   value to assign, use _absent_ or _undef_ to remove
# @param prefix
#   prefix to conf.d variable filename
# @param suffix
#   suffix to conf.d variable filename
# @param content
#   set value from content instead of ensure
#   _not supported if use_dir is disabled_
# @param source
#   set value from a source instead of ensure
#   _not supported if use_dir is disabled_
# @param enforce
#   ensure value is set at puppet runtime
# @param comment
#   comment to add to file
#
# @sample
#   sysctl::variable { 'net.ipv6.bindv6only':
#     ensure => 1
#   }
define sysctl::variable (
  Optional[String]              $variable = $title,
  Variant[String,Integer,Undef] $ensure   = undef,
  Optional[String]              $prefix   = undef,
  String                        $suffix   = '.conf',
  Optional[String]              $content  = undef,
  Optional[String]              $source   = undef,
  Boolean                       $enforce  = true,
  Optional[Variant[String,Array[String]]] $comment = undef,
) {
  if $enforce and ($content or $source) {
    fail('enforce not supported with content or source parameters')
  }
  if ($content or $source) and !$sysctl::use_dir {
    fail('content or source not supported if use_dir is disabled')
  }
  if (($content or $source) and ($ensure !~ Undef and $ensure != 'absent')) or ($content and $source) {
    fail('inconclusive parameters, set either content, source or ensure')
  }

  $params = {
    ensure          => ($ensure =~ Integer) ? {
      true  => String($ensure),
      false => $ensure,
    },
    prefix          => $prefix,
    suffix          => $suffix,
    comment         => $comment,
    content         => $content,
    source          => $source,
    enforce         => $enforce,
  }.filter |$key,$value| { $value != undef }

  if ! defined(Sysctl::Define[$variable]) {
    @sysctl::define { $variable:
      * => $params,
    }
  } else {
    Sysctl::Define <| title == $variable |> {
      * => $params,
    }
  }
}
