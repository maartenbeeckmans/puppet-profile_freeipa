#
#
#
class profile_freeipa (
  Stdlib::Fqdn             $domain                      = $::profile_base::network::domain,
  Enum['master','replica'] $ipa_role                    = 'replica',
  Boolean                  $manage_firewall             = true,
  Stdlib::Ip::Address      $ip_address                  = $::profile_base::network::ip_address,
  Stdlib::Fqdn             $ipa_master_fqdn             = 'freeipa01.cloud.beeckmans.io',
  String['8']              $puppet_admin_password,
  String['8']              $directory_services_password,
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
    enable_ip_address           => true,
    enable_hostname             => true,
    manage_host_entry           => true,
    install_epel                => false,
    ipa_master_fqdn             => $ipa_role ? {
      'master' => undef,
      default  => $ipa_master_fqdn,
    },
  }

  if $manage_firewall {
    # Add service freeipa-ldap and freeipa-ldaps
    profile_base::firewall::entry {' 00000 allow freeipa-ldap':
      port => 1234,
    }
    profile_base::firewall::entry {' 00000 allow freeipa-ldaps':
      port => 1234,
    }
}
