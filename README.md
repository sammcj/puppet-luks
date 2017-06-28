# luks

## Description

Puppet module for managing LUKS encrypted volumes

[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/sammcj/puppet-luks)

## Setup

### Beginning with LUKS

This is a very basic module for configuring encrypted volumes using LUKS on Linux.

## Usage

The following creates a LUKS device at `/dev/mapper/secretdata`, backed by
the partition at `/dev/sdb1`, encrypted with the value of `$secret_key`:

```puppet
  include ::luks

  secret_key = hiera('luks_secret')

  luks::device { 'secretdata':
    device         => '/dev/sdb1',
    key            => $secret_key,
    remove_catalog => true,
  }
```

The secret key should come from somewhere encrypted such as [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml).

## Reference

### Parameters

#### `device`
 The hardware device to back LUKS with -- any existing data will be
 lost when formatted as a LUKS device!

#### `key`
 The encryption key for the LUKS device.

#### `temp_key_path`
 The path where the decrypted key will be temporarily stored before being scrubbed.
 
 Defaults to the `/dev/shm/${name}` ramdisk.
 
#### `force_format`
 Instructs LuksFormat to run in 'batchmode' which esentially forces the block device
 to be formatted, use with care.

#### `base64`
 Set to true if the key is base64-encoded (necessary for encryption keys
 with binary data).
 
 Defaults to false.

#### `mapper`
 The name to use in `/dev/mapper` for the device.
 
 Defaults to the name to the name of the resource, i.e. `/dev/mapper/secretdata`
 

## Limitations

- At the time of writing this, it has been tested against CentOS 7.2
- **Warning**: The secret key (encrypted with the node certificate) 
  will still be cached by Puppet in the compiled catalog - _unless_ you use a null
  [catalog_cache_terminus](https://docs.puppet.com/puppet/latest/configuration.html#catalogcacheterminus) to prevent this happening.
  Examples: [https://github.com/dylanratcliffe/no_cached_catalogs](https://github.com/dylanratcliffe/no_cached_catalogs) and
  [https://github.com/ross-w/secretresource](https://github.com/ross-w/secretresource)


## Development/Release Notes/Contributors/Etc.

Please feel free to submit issues, and merge requests or generally contribute to this module.

- [Official LUKS website](https://guardianproject.info/code/luks/)
- [Module on Puppet Forge](https://forge.puppet.com/sammcj/luks/readme)
- [GitLab Mirror](https://gitlab.com/sammcj/puppet-luks/tree/master)
