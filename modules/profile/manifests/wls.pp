# Basic interface class for all WebLogic classes
class profile::wls(
  Hash      $admin_server_defaults, # Default settings for all admin servers
  Hash      $managed_server_defaults, # Default settings for all managed servers
  String    $os_user               = lookup('wls_os_user'),
  String    $os_group              = lookup('wls_os_group'),
  String    $weblogic_home_dir     = lookup('wls_weblogic_home_dir'),
  String    $middleware_home_dir   = lookup('wls_middleware_home_dir'),
  String    $oracle_base_home_dir  = lookup('wls_oracle_base_home_dir'),
  String    $jdk_home_dir          = lookup('wls_jdk_home_dir'),
  Integer   $version               = lookup('wls_version'),
  String    $domains_dir           = lookup('wls_domains_dir'),
  String    $apps_dir              = lookup('wls_apps_dir'),
  String    $weblogic_user         = lookup('wls_weblogic_user'),
  Sensitive $weblogic_password     = lookup('domain_wls_password'),
  Sensitive $nodemanager_password  = lookup('domain_nodemgr_password'),
  String    $nodemanager_username  = lookup('domain_nodemgr_username'),
  String    $adminserver_address   = lookup('domain_adminserver_address'),
  Integer   $adminserver_port      = lookup('domain_adminserver_port'),
  Integer   $nodemanager_port      = lookup('domain_nodemanager_port'),
  String    $nodemanager_address   = lookup('domain_nodemanager_address'),
)
{}
