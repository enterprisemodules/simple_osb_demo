# A regular Fusion managed server
class role::osb::node()
{
  contain ::profile::base
  contain ::wls_profile::node

  Class['::profile::base'] -> Class['::wls_profile::node']
}

 
