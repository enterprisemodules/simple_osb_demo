#
# This profile class create's a full running soa domain. It's purpose is to be used inside a profile
# defining a WebLogic domain and it's contents
#
# @example useage inside a role class
#   include profile::wls::osb::domain
#
# @param  domain_name [String] the name to use for the domain
# @param  servers [Hash] A HAsh of servers and Machines
# @param  repository_database_url [String] use following syntax jdbc:oracle:thin:@//hostname:1521/serviename
# @param  rcu_database_url [String] Use following syntax hostname:1521:service
# @param  repository_prefix [String] The prefix to use when creating RCU database users
# @param  repository_password [String] The password used when creating the RCU repository
# @param  repository_sys_password [String] The sys password of the database.
#
class profile::wls::osb::domain(
  String  $domain_name,
  Hash    $servers,
  String  $cluster_name,
  String  $repository_database_url,
  String  $rcu_database_url,
  String  $repository_prefix,
  String  $repository_password,
  String  $repository_sys_password,
  String  $rcu_soa_profile,
  Boolean $rcu_honor_omf,
  String  $domain_wls_password        = lookup('domain_wls_password', String),
  String  $domain_nodemgr_username    = lookup('domain_nodemgr_username', String),
  String  $domain_nodemgr_password    = lookup('domain_nodemgr_password', String),
)
{
  require ::profile::wls
  #
  # For consistency, you can specify here what kind of domain and clusters you want
  # Theses settings ara then applied to both the creation of the domain and to the
  # conversion of the domain. Change them the way you need them.
  #
  $bpm_enabled = false # true|false
  $bam_enabled = false # true|false
  $osb_enabled = true  # true|false
  $soa_enabled = false # true|false
  $oam_enabled = false # true|false
  $oim_enabled = false # true|false
  $b2b_enabled = false # true|false
  $ess_enabled = false # true|false

  #
  # Some general usage variables
  #
  $wls_log_dir       = "${profile::wls::oracle_base_home_dir}/logs/${domain_name}"
  $server_array      = sort(keys($servers))
  $defaults          = {
    cluster_name     => $cluster_name,
    domain_name      => $domain_name,
    nodemanager_port => $profile::wls::nodemanager_port,
    server_arguments => [
#      '-XX:PermSize=512m',
#      '-XX:MaxPermSize=1G',
#      '-Xms4G',
#      '-Xmx4G',
    ],
    require          => Wls_adminserver["${domain_name}/AdminServer"],
  }

  $admin_server_arguments = [
#    '-XX:PermSize=512m',
#    '-XX:MaxPermSize=1G',
#    '-Xms2G',
#    '-Xmx2G',
    "-Dweblogic.Stdout=${wls_log_dir}/AdminServer.out",
    "-Dweblogic.Stderr=${wls_log_dir}/AdminServer_err.out",
    ]

  #
  # This statement creates all machines and WebLogic servers. The content of
  # the $servers variable are read through hiera. Here you ca decide if your configuration
  # is a single node system or a multi-node cluster. The nodes and machines them selfs are
  # created after the domain is created.
  #
  create_resources('profile::wls::cluster_node', $servers, $defaults)

  #
  # Here you create your domain. The domain is the first thing a WebLogic installation needs. Here
  # you also decide what kind of domain you need. A bare WebLogic
  #
  wls_install::domain{$domain_name:
    domain_name                          => $domain_name,
    version                              => $profile::wls::version,
    wls_domains_dir                      => $profile::wls::domains_dir,
    wls_apps_dir                         => $profile::wls::apps_dir,
    weblogic_password                    => $domain_wls_password,
    domain_template                      => 'osb',
    bam_enabled                          => $bam_enabled,
    b2b_enabled                          => $b2b_enabled,
    ess_enabled                          => $ess_enabled,
    development_mode                     => false,
    adminserver_listen_on_all_interfaces => false,
    adminserver_address                  => $profile::wls::adminserver_address,
    adminserver_port                     => $profile::wls::adminserver_port,
    nodemanager_address                  => $profile::wls::nodemanager_address,
    nodemanager_port                     => $profile::wls::nodemanager_port,
    nodemanager_username                 => $domain_nodemgr_username,
    nodemanager_password                 => $domain_nodemgr_password,
    repository_database_url              => $repository_database_url,
    rcu_database_url                     => $rcu_database_url,
    repository_prefix                    => $repository_prefix,
    repository_password                  => $repository_password,
    repository_sys_password              => $repository_sys_password,
    rcu_honor_omf                        => $rcu_honor_omf,
    rcu_soa_profile                      => $rcu_soa_profile,
    log_dir                              => $wls_log_dir,
    logoutput                            => false,  # When debugging, set this to true
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

  #
  # Before you can manage any WebLogic objects, you'll need to have a running admin server.
  # This code makes sure the admin server is started. Just like with the nodemanager, you'll need
  # to specify unique addresses and ports.
  #
  -> wls_install::control{"start_adminserver_${domain_name}":
    action              => 'start',
    domain_name         => $domain_name,
    adminserver_address => $profile::wls::adminserver_address,
    adminserver_port    => $profile::wls::adminserver_port,
    nodemanager_port    => $profile::wls::nodemanager_port,
    weblogic_user       => $profile::wls::weblogic_user,
    weblogic_password   => $profile::wls::weblogic_password,
    os_user             => $profile::wls::os_user,
  }

  #
  # wls_setting is used to store the credentials and connect URL of a domain. The Puppet
  # types need this to connect to the admin server and change settings.
  #
  -> wls_setting{$domain_name:
    user              => $profile::wls::os_user,
    weblogic_user     => $profile::wls::weblogic_user,
    weblogic_password => $profile::wls::weblogic_password,
    connect_url       => "t3://${profile::wls::adminserver_address}:${profile::wls::adminserver_port}",
    weblogic_home_dir => $profile::wls::weblogic_home_dir,
  }

  #
  # You can use this wls_server definition to change any settings for your
  # Admin server. because the AdminServer is restarted by wls_adminserver{'osb/AdminServer':}
  # These settings are immediately applied
  #
  -> wls_server{"${domain_name}/AdminServer":
    ensure                        => 'present',
    arguments                     => $admin_server_arguments,
    listenaddress                 => $profile::wls::adminserver_address,
    listenport                    => $profile::wls::adminserver_port,
    logfilename                   => "${wls_log_dir}/AdminServer.log",
    log_datasource_filename       => "${wls_log_dir}/datasource.log",
    log_http_filename             => "${wls_log_dir}/access.log",
    log_redirect_stderr_to_server => '1',
    log_redirect_stdout_to_server => '1',
    *                             => $profile::wls::admin_server_defaults,
  }

  #
  # This definition restarts the Admin server. It is a refresh-only, so it is only done
  # when the statement before actually changed something.
  #
  # If changes are made to the adminserver, We need to restart it
  ~> wls_adminserver{"${domain_name}/AdminServer":
    ensure              => running,
    refreshonly         => true,
    server_name         => 'AdminServer',
    domain_name         => $domain_name,
    domain_path         => "${profile::wls::domains_dir}/${domain_name}",
    os_user             => $profile::wls::os_user,
    nodemanager_address => $profile::wls::nodemanager_address,
    nodemanager_port    => $profile::wls::nodemanager_port,
    weblogic_user       => $profile::wls::weblogic_user,
    weblogic_password   => $profile::wls::weblogic_password,
    weblogic_home_dir   => $profile::wls::weblogic_home_dir,
    subscribe           => Wls_install::Domain[$domain_name],
  }

  #
  # This is the cluster definition. The server array is extracted from the list of servers
  # and machines,
  #
  -> wls_cluster{"${domain_name}/${cluster_name}":
    ensure         => 'present',
    messagingmode  => 'unicast',
    migrationbasis => 'database',
    servers        => $server_array,
  }

  #
  # This definition changes current servers and cluster setup into a correct
  # Fusion Middleware setup. If you change this, make sure the ..._enabled settings are the
  # same as the one you set when creating the domain.
  #
  -> wls_install::utils::fmwcluster{$cluster_name:
    domain_name         => $domain_name,
    repository_prefix   => $repository_prefix,
    soa_cluster_name    => $cluster_name,
    osb_cluster_name    => $cluster_name,
    bam_cluster_name    => $cluster_name,
    ess_cluster_name    => $cluster_name,
    adminserver_address => $profile::wls::adminserver_address,
    adminserver_port    => $profile::wls::adminserver_port,
    nodemanager_port    => $profile::wls::nodemanager_port,
    bam_enabled         => $bam_enabled,
    bpm_enabled         => $bpm_enabled,
    soa_enabled         => $soa_enabled,
    osb_enabled         => $osb_enabled,
    b2b_enabled         => $b2b_enabled,
    ess_enabled         => $ess_enabled,
    logoutput           => false,  # When debugging, set this to true
  }

  -> wls_install::fmwlogdir{'AdminServer':
    log_dir => $wls_log_dir,
  }

  # create setUserOverrides.sh in domain_dir/bin directory
  -> file { 'setUserOverrides':
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
  # This definition creates a pack of the domain for distrobution to managed servers on other machines
  #
  -> wls_install::packdomain{$domain_name:
    weblogic_home_dir   => $profile::wls::weblogic_home_dir,
    middleware_home_dir => $profile::wls::middleware_home_dir,
    jdk_home_dir        => $profile::wls::jdk_home_dir,
    wls_domains_dir     => $profile::wls::domains_dir,
    domain_name         => $domain_name,
    os_user             => $profile::wls::os_user,
    os_group            => $profile::wls::os_user,
    download_dir        => $profile::wls::domains_dir,
  }

  -> file {"/vagrant/domain_${domain_name}.jar":
    ensure => 'present',
    source => "${profile::wls::domains_dir}/domain_${domain_name}.jar"
  }

  #
  # This class create's a startup script in /etc/init.d.
  #
  -> wls_install::support::nodemanagerautostart{"${domain_name}_nodemanager":
    version     => $profile::wls::version,
    wl_home     => $profile::wls::weblogic_home_dir,
    user        => $profile::wls::os_user,
    domain      => $domain_name,
    log_dir     => $wls_log_dir,
    domain_path => "${profile::wls::domains_dir}/${domain_name}",
  }
}
