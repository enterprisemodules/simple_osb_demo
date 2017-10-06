#
# This profile class create's a managed server for a clustered osb domain.
#
# @example useage inside a role class
#   include profile::wls::osb::domain
#
#
class profile::wls::osb::managed_server(
  String  $domain_name,
)
{
  require ::profile::wls
  #

  $wls_log_dir       = "${profile::wls::oracle_base_home_dir}/logs/${domain_name}"

  wls_install::copydomain{$domain_name:
    version             => $profile::wls::version,
    weblogic_home_dir   => $profile::wls::weblogic_home_dir,
    middleware_home_dir => $profile::wls::middleware_home_dir,
    jdk_home_dir        => $profile::wls::jdk_home_dir,
    wls_domains_dir     => $profile::wls::domains_dir,
    wls_apps_dir        => $profile::wls::apps_dir,
    domain_name         => $domain_name,
    os_user             => $profile::wls::os_user,
    os_group            => $profile::wls::os_user,
    download_dir        => $profile::wls::domains_dir,
    log_dir             => $wls_log_dir,
    log_output          => true,
    use_ssh             => true,
    domain_pack_dir     => $profile::wls::domains_dire,
    adminserver_address => $profile::wls::adminserver_address,
    adminserver_port    => $profile::wls::adminserver_port,
    weblogic_user       => $profile::wls::weblogic_user,
    weblogic_password   => $profile::wls::weblogic_password,
    server_start_mode   => 'prod'
  }

  # create setUserOverrides.sh in domain_dir/bin directory
  ->file { 'setUserOverrides':
    ensure  => present,
    path    => "${profile::wls::domains_dir}/${domain_name}/bin/setUserOverrides.sh",
    content => template('profile/setUserOverrides.sh.erb'),
    replace => true,
    mode    => '0775',
    owner   => $profile::wls::os_user,
    group   => $profile::wls::os_group,
    backup  => false,
  }

  #
  # This class create's a startup script in /etc/init.d.
  #
  ->wls_install::support::nodemanagerautostart{"${domain_name}_nodemanager":
    version                 => $profile::wls::version,
    wl_home                 => $profile::wls::weblogic_home_dir,
    user                    => $profile::wls::os_user,
    domain                  => $domain_name,
    log_dir                 => $wls_log_dir,
    domain_path             => "${profile::wls::domains_dir}/${domain_name}",
    systemd_script_location => "${profile::wls::oracle_base_home_dir}/config",
  }
}
