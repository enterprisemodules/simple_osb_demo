# Install the firts node of a SOA cluster.
class role::wls::osb_master()
{
  contain ::profile::base
  contain ::profile::wls::os
  contain ::profile::java
  contain ::profile::wls::software
  contain ::profile::wls::fmw_software
  contain ::profile::wls::osb

  Class['::profile::base']
  ->Class['::profile::wls::os']
  ->Class['::profile::java']
  ->Class['::profile::wls::software']
  ->Class['::profile::wls::fmw_software']
  ->Class['::profile::wls::osb']
}
