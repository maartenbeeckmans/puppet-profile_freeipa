#
#
#
class profile_freeipa (
  Optional[String[8]]      $puppet_admin_password,
  Optional[String[8]]      $directory_services_password,
  Optional[String[8]]      $domain_join_password,
  Stdlib::Fqdn             $ipa_master_fqdn,
  Stdlib::Fqdn             $domain,
  Enum['master','replica'] $ipa_role,
  Boolean                  $manage_firewall_entry,
  Stdlib::Ip::Address      $ip_address,
  Stdlib::Fqdn             $ipa_server_fqdn,
  String                   $sd_service_name_http,
  Array[String]            $sd_service_tags_http,
  String                   $sd_service_name_https,
  Array[String]            $sd_service_tags_https,
  String                   $sd_service_name_ldap,
  Array[String]            $sd_service_tags_ldap,
  String                   $sd_service_name_ldaps,
  Array[String]            $sd_service_tags_ldaps,
  Boolean                  $manage_sd_service            = lookup('manage_sd_service', Boolean, first, true),
) {
  if $facts['os']['family'] == 'RedHat' {
    package { '@idm:DL1':
      ensure => present,
      before => Class['Freeipa'],
    }
  }

  case $ipa_role {
    'master': {
      class { 'freeipa':
        ipa_role                    => 'master',
        domain                      => $domain,
        ipa_server_fqdn             => $ipa_server_fqdn,
        puppet_admin_password       => $puppet_admin_password,
        directory_services_password => $directory_services_password,
        install_ipa_server          => true,
        ip_address                  => $ip_address,
        idstart                     => 100000,
        enable_ip_address           => true,
        enable_hostname             => true,
        configure_dns_server        => false,
        manage_host_entry           => true,
        install_epel                => false,
        webui_redirect              => false,
        ipa_master_fqdn             => $ipa_master_fqdn,
      }
    }
    'replica': {
      class { 'freeipa':
        ipa_role                    => 'replica',
        domain                      => $domain,
        ipa_server_fqdn             => $ipa_server_fqdn,
        puppet_admin_password       => $puppet_admin_password,
        directory_services_password => $directory_services_password,
        install_ipa_server          => true,
        ip_address                  => $ip_address,
        idstart                     => 100000,
        enable_ip_address           => true,
        enable_hostname             => true,
        manage_host_entry           => true,
        configure_dns_server        => false,
        install_epel                => false,
        ipa_master_fqdn             => $ipa_master_fqdn,
      }
    }
    default: {
      # Will never do this, adding for linter
    }
  }


  if $manage_firewall_entry {
    firewall { '00080 allow freeipa http':
      dport  => 80,
      action => 'accept',
    }
    firewall { '00088 allow freeipa kerberos tcp':
      dport  => 88,
      action => 'accept',
      proto  => 'tcp',
    }
    firewall { '00088 allow freeipa kerberos udp':
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

  if $manage_sd_service {
    consul::service { $sd_service_name_http:
      checks => [
        {
          http            => "http://${ipa_server_fqdn}:80/ipa/ui",
          interval        => '10s',
          tls_skip_verify => true,
        }
      ],
      port   => 80,
      tags   => $sd_service_tags_http,
    }

    consul::service { $sd_service_name_https:
      checks => [
        {
          http            => "https://${ipa_server_fqdn}:443/ipa/ui",
          interval        => '10s',
          tls_skip_verify => true,
        }
      ],
      port   => 80,
      tags   => $sd_service_tags_https,
    }

    consul::service { $sd_service_name_ldap:
      checks => [
        {
          tcp      => "${ipa_server_fqdn}:389",
          interval => '10s',
        }
      ],
      port   => 389,
      tags   => $sd_service_tags_ldap,
    }

    consul::service { $sd_service_name_ldaps:
      checks => [
        {
          tcp      => "${ipa_server_fqdn}:636",
          interval => '10s',
        }
      ],
      port   => 636,
      tags   => $sd_service_tags_ldaps,
    }
  }

  include profile_freeipa::ssh
}
