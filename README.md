[![Gem Version](https://badge.fury.io/rb/capistrano-net_storage.svg)](https://badge.fury.io/rb/capistrano-net_storage)
[![Test](https://github.com/DeNADev/capistrano-net_storage/actions/workflows/test.yml/badge.svg)](https://github.com/DeNADev/capistrano-net_storage/actions/workflows/test.yml?query=branch%3Amaster)

# Capistrano::NetStorage

**Capistrano::NetStorage** is a [Capistrano](http://capistranorb.com/) plugin to deploy application
via _remote storage_ such as [Amazon S3](https://aws.amazon.com/s3/),
[Google Cloud Storage](https://cloud.google.com/storage/) and so on.

Logically, this tool enables _O(1)_ deployment.


## Concept

The image below illustrates the concept of **Capistrano::NetStorage**.

![concept](docs/images/concept.png)

This library conducts the following procedures as _capistrano tasks_:

1. Prepare an archive of application to upload.
  * Clone and update source code repository on deploy server.
  * Extract the internals to local release directory.
  * Further prepare the local release. (e.g. `bundle install` and `assets:precompile`)
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

#### General Settings

 Name | Default | Description
------|---------|------------
 `:net_storage_transport` | NO DEFAULT | Transport class for _remote storage_ e.g. `Capistrano::NetStorage::S3`
 `:net_storage_config_files` | `[]` | Files to sync `config/` directory on target servers' application directory

#### Settings for Behavioral Changes

 Name | Default | Description
------|---------|------------
 `:net_storage_skip_bundle` | `false` | Skip `bundle install` when creating archive (might be work for non-Ruby app)
 `:net_storage_multi_app_mode` | `false` | Deploy a repository with multiple Rails apps at the top directory

#### Other Settings

**NOTE: We strongly recommend the defaults for integrity and performance. Change at your own risk.**

 Name | Default | Description
------|---------|------------
 `:net_storage_archiver` | `Capistrano::NetStorage::Archiver::TarGzip` | Archiver class
 `:net_storage_scm` | `Capistrano::NetStorage::SCM::Git` | Internal scm class for application repository
 `:net_storage_upload_files_by_rsync` | `true` | Use rsync(1) to deploy config files
 `:net_storage_rsync_options` | `#{ssh_options}` | SSH options for rsync command to sync configs
 `:net_storage_max_parallels` | 1000 | Max concurrency for remote tasks. (This default is being tuned by maintainers.)
 `:net_storage_reuse_archive` | `true` | If `true`, it reuses archive with the same commit hash at remote storage and uploads archives only when it does not exist.
 `:net_storage_local_base_path` | `.local_net_storage` | Base directory on deploy server
 `:net_storage_archives_path` | `#{deploy_to}/net_storage_archives` | Archive directories on application server
 `:net_storage_keep_remote_archives` | 10 | Number of archive files keep on remote storage

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

When you want to further prepare the release before deployment, you can write it as follows:

```ruby
namespace :your_namespace do
  task :prepare_archive do
    run_locally do
      within Capistrano::NetStorage.config.local_release_app_path do
        # The resultant artifacts are to be archived with other files
        execute :bundle, 'exec', 'rake', 'build_in_memory_cache_bundle'
        execute :bundle, 'exec', 'rake', 'assets:precompile'
      end
    end
  end
end

after 'net_storage:prepare_archive', 'your_namespace:prepare_archive'
```

## License

Available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Copyright (c) 2017 DeNA Co., Ltd., IKEDA Kiyoshi

## Special Thanks

The previous version of this program was originally developed by @bobpp.
