# TODO: Write documentation
define profile::wls::managed_server(
  String  $domain,
  String  $machine,
  String  $cluster_name,
  String  $listenaddress,
  Integer $listenport,
  Integer $ssllistenport,
  Array   $server_arguments,
)
{

  require ::profile::wls

  $wls_log_dir = "${profile::wls::oracle_base_home_dir}/logs/${domain}"
  $log_arguments = [
    "-Dweblogic.Stdout=${wls_log_dir}/${title}.out",
    "-Dweblogic.Stderr=${wls_log_dir}/${title}_err.out",
  ]

  $full_arguments = $server_arguments + $log_arguments

  wls_server{"${domain}/${title}":
    ensure                         => present,
    listenaddress                  => $listenaddress,
    listenport                     => $listenport,
    arguments                      => $full_arguments,
    logfilename                    => "${wls_log_dir}/${title}.log",
    machine                        => $machine,
    log_datasource_filename        => "${wls_log_dir}/datasource.log",
    log_http_filename              => "${wls_log_dir}/access.log",
    log_redirect_stderr_to_server  => '1',
    log_redirect_stdout_to_server  => '1',
    ssllistenport                  => $ssllistenport,
    sslhostnameverificationignored => 1,
    jsseenabled                    => 1,
    tunnelingenabled               => 1,
    weblogic_plugin_enabled        => '1',
    *                              => $profile::wls::managed_server_defaults
  }

  ->wls_install::fmwlogdir{$title:
    server  => $title,
    log_dir => $wls_log_dir,
  }

}
