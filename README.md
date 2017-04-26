# luks

## Description

Puppet module for managing LUKS encrypted volumes
It should be considered a **WORK IN PROGRESS** - expect bugs and feel free to log issues or contribute fixes

## Setup

### Beginning with LUKS

This is a very basic module for configuring encrypted volumes using LUKS on Linux.

## Usage

The following creates a LUKS device at '/dev/mapper/secretdata', backed by
the partition at '/dev/sdb1', encrypted with the key 'agoodsecretkey':

```puppet
  include ::luks

  secret_key = hiera('luks_secret')

  luks::device { 'secretdata':
    device         => '/dev/sdb1',
    key            => $secret_key,
    remove_catalog => true,
  }
```

In practise the key should come from somewhere encrypted such as hiera-eyaml.

## Reference

### Parameters

#### `device`
 The hardware device to back LUKS with -- any existing data will be
 lost when formatted as a LUKS device!

#### `key`
 The encryption key for the LUKS device.

#### `base64`
 Set to true if the key is base64-encoded (necessary for encryption keys
 with binary data); defaults to false.

#### `mapper`
 The name to use in `/dev/mapper` for the device, defaults to the name
 to the name of the resource.

#### `temp`
 Path to temporary file to store the encryption key in, defaults to
 "/dev/shm/${name}".

## Limitations

- At the time of writing this, it has been tested against CentOS 7.2
- **Warning**: This will overwrite any existing data on the specified device
- **Warning**: The secret key may still be cached by Puppet in the compiled catalog
  (/var/lib/puppet/client_data/catalog/*.json)  To prevent this secret from
  persisting on disk you will have still have delete this file via some
  mechanism, e.g., through a cron task or configuring the Puppet agent to
  run a [`postrun_command`](http://docs.puppetlabs.com/references/stable/configuration.html#postruncommand)

## Development

Please feel free to submit issues, and merge requests or generally contribute to this module.

## Release Notes/Contributors/Etc.

- Thanks to @counsyl as this module has borrowed LUKS specific code from the [puppet-sys](https://github.com/counsyl/puppet-sys) module.
- [Official LUKS website](https://guardianproject.info/code/luks/)
