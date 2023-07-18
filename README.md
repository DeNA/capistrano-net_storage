[![Gem Version](https://badge.fury.io/rb/capistrano-net_storage.svg)](https://badge.fury.io/rb/capistrano-net_storage)
[![Test](https://github.com/DeNADev/capistrano-net_storage/actions/workflows/test.yml/badge.svg)](https://github.com/DeNADev/capistrano-net_storage/actions/workflows/test.yml?query=branch%3Amaster)

# Capistrano::NetStorage

**Capistrano::NetStorage** is a [Capistrano](http://capistranorb.com/) plugin to deploy application
via _remote storage_ such as [Amazon S3](https://aws.amazon.com/s3/),
[Google Cloud Storage](https://cloud.google.com/storage/) and so on.

Logically, this tool enables _O(1)_ deployment.


## Concept

The image below illustrates the concept of **Capistrano::NetStorage**.

![concept](https://github.com/DeNADev/capistrano-net_storage/raw/resource/images/concept.png)

This library goes following procedures as _capistrano tasks_:

1. Prepare an archive of application to upload.
  * Clone or update source code repository on deploy server.
  * Do `bundle install` by an option.
2. Upload the archive to _remote storage_.
3. Download the archive from _remote storage_ on application servers.
  * This task is executed in parallel way.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-net_storage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-net_storage

## Configuration

Set Capistrano variables by `set name, value`.

 Name | Default | Description
------|---------|------------
 `:scm`  | `nil` | Set `:net_storage` for capistrano before v3.7
 `:branch` | `master` | Target branch of SCM to release
 `:keep_releases` | `5` | Numbers to keep released versions
 `:net_storage_archiver` | `Capistrano::NetStorage::Archiver::TarGzip` | Archiver class
 `:net_storage_scm` | `Capistrano::NetStorage::SCM::Git` | Internal scm class for application repository
 `:net_storage_transport` | `nil` | Transport class for _remote storage_
 `:net_storage_archive_on_missing` | `true` | If `true`, create and upload archive only when target archive is missing on remote storage
 `:net_storage_config_files` | `[]` | Files to sync `config/` directory on target servers' application directory
 `:net_storage_max_parallels` | number of servers | Max concurrency for remote tasks
 `:net_storage_rsync_options` | `#{ssh_options}` | SSH options for rsync command to sync configs
 `:net_storage_upload_files_by_rsync` | `false` | Use rsync(1) to deploy config files
 `:net_storage_skip_bundle` | `false` | Skip `bundle install` when creating archive
 `:net_storage_local_base_path` | `.local_repo` | Base directory on deploy server
 `:net_storage_local_mirror_path` | `#{net_storage_local_base_path}/mirror` | Path to clone repository on deploy server
 `:net_storage_local_releases_path` | `#{net_storage_local_base_path}/releases` | Path to keep release directories on deploy server
 `:net_storage_local_bundle_path` | `#{net_storage_local_base_path}/bundle` | Shared directory to install gems on deploy server
 `:net_storage_local_archives_path` | `#{net_storage_local_base_path}/archives` | Archive directories on deploy server
 `:net_storage_archives_path` | `#{deploy_to}/net_storage_archives` | Archive directories on application server
 `:net_storage_multi_app_mode` | `false` | Deploy a repository with multiple Rails apps at the top directory

### Transport Plugins

Here are available plugins list which serves as `:net_storage_transport`:

- [Capistrano::NetStorage::S3::Transport](https://github.com/DeNADev/capistrano-net_storage-s3) for [Amazon S3](https://aws.amazon.com/s3/)

If you wish a plugin for other types of _remote storage_, you can develop it. It should inherit
`Capistrano::NetStorage::Transport::Base` class.

## Usage

Edit Capfile:

```ruby
# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
if Gem::Version.new(Capistrano::VERSION) < Gem::Version.new('3.7.0')
  require 'capistrano/net_storage'
else
  require "capistrano/net_storage/plugin"
  install_plugin Capistrano::NetStorage::Plugin
end

# Load transport plugin for Capistrano::NetStorage
# require 'capistrano/net_storage/s3'
```

Edit your `config/deploy.rb`:

```ruby
if Gem::Version.new(Capistrano::VERSION) < Gem::Version.new('3.7.0')
  set :scm, :net_storage
end
set :net_storage_transport, Your::TransportPluginModule
# set :net_storage_transport, Capistrano::NetStorage::S3::Transport # w/ capistrano-net_storage-s3
# set :net_storage_config_files, [your_config_files]
# set :net_storage_with_bundle, true
# set :net_storage_archiver, Capistrano::NetStorage::Archiver::TarGzip
```

## Example

You can see typical usage of this library by
[capistrano-net_storage_demo](https://github.com/DeNADev/capistrano-net_storage_demo).

## License

Available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Copyright (c) 2017 DeNA Co., Ltd., IKEDA Kiyoshi

## Special Thanks

The previous version of this program was originally developed by @bobpp.
