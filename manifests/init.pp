#
#
#
class profile_freeipa (
  String[8]                $puppet_admin_password,
  String[8]                $directory_services_password,
  Stdlib::Fqdn             $ipa_master_fqdn,
  Stdlib::Fqdn             $domain                      = $facts['networking']['domain'],
  Enum['master','replica'] $ipa_role                    = 'replica',
  Boolean                  $manage_firewall_entry       = true,
  Stdlib::Ip::Address      $ip_address                  = $facts['networking']['ip'],
  Stdlib::Fqdn             $ipa_server_fqdn             = $facts['networking']['fqdn'],
) {
  class { 'freeipa':
    ipa_role                    => $ipa_role,
    domain                      => $domain,
    ipa_server_fqdn             => $ipa_server_fqdn,
    puppet_admin_password       => $ipa_role ? {
      'master' => $puppet_admin_password,
      default  => undef,
    },
    directory_services_password => $ipa_role ? {
      'master' => $directory_services_password,
      default  => undef,
    },
    install_ipa_server          => true,
    ip_address                  => $ip_address,
    idstart                     => 100000,
    enable_ip_address           => true,
    enable_hostname             => true,
    configure_dns_server        => false,
    manage_host_entry           => true,
    install_epel                => false,
    ipa_master_fqdn             => $ipa_master_fqdn,
  }

  if $manage_firewall_entry {
    firewall { '00080 allow freeipa http':
      dport  => 80,
      action => 'accept',
    }
    firewall { '00088 allow freeipa http tcp':
      dport  => 88,
      action => 'accept',
      proto  => 'tcp',
    }
    firewall { '00088 allow freeipa http udp':
      dport  => 88,
      action => 'accept',
      proto  => 'udp',
    }
    firewall { '00123 allow freeipa ntp udp':
      dport  => 123,
      action => 'accept',
      proto  => 'udp',
    }
    firewall { '00389 allow freeipa ldap':
      dport  => 389,
      action => 'accept',
    }
    firewall { '00443 allow freeipa http':
      dport  => 443,
      action => 'accept',
    }
    firewall { '00464 allow freeipa kerberos tcp':
      dport  => 464,
      action => 'accept',
      proto  => 'tcp',
    }
    firewall { '00464 allow freeipa kerberos udp':
      dport  => 464,
      action => 'accept',
      proto  => 'udp',
    }
    firewall { '00636 allow freeipa ldaps':
      dport  => 636,
      action => 'accept',
    }
  }
}
