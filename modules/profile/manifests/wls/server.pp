#
# @example usage inside a role class
#   include profile::wls::server
#
# @param  domain_name [String] the name to use for the domain
#
class profile::wls::server(
  String  $domain_name,
)
{
  require ::profile::wls

  $wls_log_dir       = "${profile::wls::oracle_base_home_dir}/logs/${domain_name}"

  #
  # For now we will fetch the file from the vagrant directory. In a real enterprise environment
  # You can use ssh or a shared nfs folder.
  #
  wls_install::copydomain{$domain_name:
    domain_name         => $domain_name,
    version             => $profile::wls::version,
    weblogic_home_dir   => $profile::wls::weblogic_home_dir,
    middleware_home_dir => $profile::wls::middleware_home_dir,
    jdk_home_dir        => $profile::wls::jdk_home_dir,
    wls_domains_dir     => $profile::wls::domains_dir,
    os_user             => $profile::wls::os_user,
    os_group            => $profile::wls::os_group,
    download_dir        => '/data/install',
    log_dir             => '/var/log/weblogic',
    logoutput           => false,
    use_ssh             => false,
    domain_pack_dir     => '/vagrant',
    adminserver_address => $profile::wls::adminserver_address,
    adminserver_port    => $profile::wls::adminserver_port,
    weblogic_user       => $profile::wls::weblogic_user,
    weblogic_password   => $profile::wls::weblogic_password,
  }

  #
  # Over here you define the nodemanager. Here you can specify the address
  # the nodemanager is running on and the listen address. When you create multiple domains
  # with multiple nodemanagers, you have to specify different addresses and/or ports.
  #
  -> wls_install::nodemanager{"nodemanager for ${domain_name}":
    domain_name         => $domain_name,
    version             => $profile::wls::version,
    nodemanager_address => $profile::wls::nodemanager_address,
    nodemanager_port    => $profile::wls::nodemanager_port,
    log_dir             => $wls_log_dir,
    sleep               => 60,
  }

}
