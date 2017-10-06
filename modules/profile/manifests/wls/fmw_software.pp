# Install the Fusion Software
class profile::wls::fmw_software(
  Integer $version,
  String  $filename,
  String  $product,
  Boolean $bpm = false
) {

  wls_install::fmw{$filename:
    version     => $version,
    fmw_file1   => $filename,
    fmw_product => $product,
    bpm         => $bpm,
    remote_file => true,
    source      => 'puppet:///modules/software',
    log_output  => false,
  }
}
