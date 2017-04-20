# Class: luks
# ===========================
# A simple module that installs cryptsetup, necessary for LUKS (Linux Unifed Key Setup).
#
# Currently supports / is tested on RHEL 7 and derivatives such as CentOS 7.
# Requires the main class to the included and a device to be defined (see example below)
#
# === Parameters
#
# [*device*]
#  The hardware device to back LUKS with -- any existing data will be
#  lost when formatted as a LUKS device!
#
# [*key*]
#  The encryption key for the LUKS device.
#
# [*base64*]
#  Set to true if the key is base64-encoded (necessary for encryption keys
#  with binary data); defaults to false.
#
# [*mapper*]
#  The name to use in `/dev/mapper` for the device, defaults to the name
#  to the name of the resource.
#
# [*puppet_conf_file*]
# Path to the Puppet conf file
# For Puppet Enterprise this should be changed to '/etc/puppetlabs/puppet/puppet.conf'
#
# [*puppet_catalog*]
# For Puppet Enterprise this should be changed to '/opt/puppetlabs/puppet/cache/client_data/catalog/*.json'
#
# === Example
#
# The following creates a LUKS device at '/dev/mapper/data', backed by
# the partition at '/dev/sdb1', encrypted with a key from hiera (hopefully eyaml!):
#
#  include ::luks
#
#  secret_key = hiera('luks_secret')
#
#  luks::device { 'secretdata':
#    device         => '/dev/sdb1',
#    key            => $secret_key,
#  }
#
# Copyright 2017 Sam McLeod.
#

class luks(
  $ensure  = latest,
  $package = 'cryptsetup',
  $remove_catalog = false,
  $puppet_conf_file = '/etc/puppet/puppet.conf',
  $puppet_catalog = '/var/lib/puppet/client_data/catalog/*.json',
  $shred = '/usr/bin/shred --iterations 3 --random=/dev/urandom',
) {

  package { $package:
    ensure => $ensure,
  }

  if $remove_catalog == true {
    # Ensure that the locally cached catalog is removed after each puppet run
    # as it may contain the LUKS key
    file_line { 'remove_catalog' :
      line  => "     postrun_command=${shred} ${puppet_catalog}",  #TODO make this nicer
      path  => $puppet_conf_file,
      after => '[main]',
    }
  }
}
