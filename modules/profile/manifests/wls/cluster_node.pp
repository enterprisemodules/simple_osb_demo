#
# == Define: wls_install::cluster_node
#
# Create's a machine and a managed server for all specified nodes
# in a Weblogic cluster.
#
#
define profile::wls::cluster_node(
  $machine_name,
  $listenaddress,
  $listen_port,
  $ssl_listen_port,
  $nodemanager_port,
  $domain_name,
  $cluster_name,
  $server_arguments,
)
{
  wls_machine {"${domain_name}/${machine_name}":
    ensure        => 'present',
    listenaddress => $listenaddress,
    listenport    => $nodemanager_port,
    machinetype   => 'UnixMachine',
    nmtype        => 'SSL',
  }

  profile::wls::managed_server{$title:
    domain           => $domain_name,
    machine          => $machine_name,
    listenaddress    => $listenaddress,
    server_arguments => $server_arguments,
    listenport       => $listen_port,
    ssllistenport    => $ssl_listen_port,
    cluster_name     => $cluster_name,
  }
}
