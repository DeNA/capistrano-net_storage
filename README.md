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

NOTE:

* You need to prepare a _transport class_ to execute upload/download operation suitable for
_remote storage_. It should inherit `Capistrano::NetStorage::Transport::Base` class.

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
 `:scm`  | `nil` | Set `:net_storage`
 `:branch` | `master` | Target branch of SCM to release
 `:keep_releases` | `5` | Numbers to keep released versions
 `:net_storage_transport` | `nil` | Transport class for _remote storage_
 `:net_storage_archiver` | `Capistrano::NetStorage::Archiver::Zip` | Archiver class
 `:net_storage_scm` | `Capistrano::NetStorage::SCM::Git` | Internal scm class for application repository
 `:net_storage_with_bundle` | `false` | Do `bundle install` when creating archive
 `:net_storage_config_files` | `nil` | Files to sync `config/` directory on target servers' application directory
 `:net_storage_max_parallels` | number of servers | Max concurrency for remote tasks
 `:net_storage_archive_on_missing` | `true` | If `true`, create and upload archive only when target archive is missing on remote storage
 `:net_storage_upload_files_by_rsync` | `false` | Use rsync(1) to deploy config files
 `:net_storage_local_base_path` | `.local_repo` | Base directory on deploy server

### Transport Plugins

Here are available plugins list which serves as `:net_storage_transport`:

- [Capistrano::NetStorage::S3::Transport](https://github.com/DeNADev/capistrano-net_storage-s3)

## Usage

Edit Capfile:

```ruby
# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
require 'capistrano/net_storage'
# Load transport plugin
# require 'capistrano/net_storage/s3'
```

Edit your `config/deploy.rb`:

```ruby
set :scm, :net_storage
set :net_storage_transport, Your::TransportPluginModule
# set :net_storage_transport, Capistrano::NetStorage::S3::Transport # w/ capistrano-net_storage-s3
# set :net_storage_config_files, [your_config_files]
# set :net_storage_with_bundle, true
# set :net_storage_archiver, Capistrano::NetStorage::Archiver::TarGzip
```

## Example

You can see typical usage of this library by
[capistrano-net_storage_demo](https://github.com/DeNADev/capistrano-net_storage_demo).

## TODO

* Support
[Capistrano SCM plugin system](http://capistranorb.com/documentation/advanced-features/custom-scm/)
introduced in Capistrano v3.7

## License

Available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Copyright (c) 2017 DeNA Co., Ltd., IKEDA Kiyoshi

