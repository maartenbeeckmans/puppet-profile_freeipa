#
#
#
class profile_freeipa::ssh {
  sshd_config { 'PubkeyAuthentication':
    ensure => present,
    value  => 'yes',
  }
  sshd_config { 'KerberosAuthentication':
    ensure => present,
    value  => 'no'
  }
  sshd_config { 'GSSAPIAuthentication':
    ensure => present,
    value  => 'yes',
  }
  sshd_config { 'AuthorizedKeysCommand':
    ensure => present,
    value  => '/usr/bin/sss_ssh_authorizedkeys',
  }
  sshd_config { 'AuthorizedKeysCommandUser':
    ensure => present,
    value  => 'nobody',
  }
}
