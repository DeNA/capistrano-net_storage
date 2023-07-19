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

You can consult configuration of Capistrano itself at https://capistranorb.com/documentation/getting-started/configuration/

Configurations of Capistrano::NetStorage are as follows:

 Name | Default | Description
------|---------|------------
 `:net_storage_transport` | NO DEFAULT | Transport class for _remote storage_ e.g. `Capistrano::NetStorage::S3`
 `:net_storage_archiver` | `Capistrano::NetStorage::Archiver::TarGzip` | Archiver class
 `:net_storage_scm` | `Capistrano::NetStorage::SCM::Git` | Internal scm class for application repository
 `:net_storage_config_files` | `[]` | Files to sync `config/` directory on target servers' application directory
 `:net_storage_upload_files_by_rsync` | `true` | Use rsync(1) to deploy config files
 `:net_storage_rsync_options` | `#{ssh_options}` | SSH options for rsync command to sync configs
 `:net_storage_max_parallels` | `release_roles(:all).size` | Max concurrency for remote tasks
 `:net_storage_reuse_archive` | `true` | If `true`, it reuses archive with the same commit hash at remote storage and uploads archives only when it does not exist.
 `:net_storage_local_base_path` | `.local_repo` | Base directory on deploy server
 `:net_storage_archives_path` | `#{deploy_to}/net_storage_archives` | Archive directories on application server
 `:net_storage_skip_bundle` | `false` | Skip `bundle install` when creating archive
 `:net_storage_multi_app_mode` | `false` | Deploy a repository with multiple Rails apps at the top directory

### Transport Plugins

Here are available plugins list which serves as `:net_storage_transport`:

- [Capistrano::NetStorage::S3::Transport](https://github.com/DeNADev/capistrano-net_storage-s3) for [Amazon S3](https://aws.amazon.com/s3/)

If you wish a plugin for other types of _remote storage_, you can develop it. It should inherit
`Capistrano::NetStorage::Transport::Base` class.

## Usage

Below is the typical usage of Capistrano::NetStorage.

Edit Capfile:

```ruby
# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
require "capistrano/net_storage/plugin"
install_plugin Capistrano::NetStorage::Plugin

# Load transport plugin for Capistrano::NetStorage
require 'capistrano/net_storage/s3' # or your_custom_transport
```

Edit your `config/deploy.rb`:

```ruby
set :net_storage_transport, Capistrano::NetStorage::S3::Transport # or YourCustomTransport class
set :net_storage_config_files, Pathname('path/to/config').glob('*.yml')
```

## Example

You can see typical usage of this library by
[capistrano-net_storage_demo](https://github.com/DeNADev/capistrano-net_storage_demo).

## License

Available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Copyright (c) 2017 DeNA Co., Ltd., IKEDA Kiyoshi

## Special Thanks

The previous version of this program was originally developed by @bobpp.
