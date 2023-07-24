require 'capistrano/net_storage/scm/base'

# Internal SCM class for Git repository
class Capistrano::NetStorage::SCM::Git < Capistrano::NetStorage::SCM::Base
  def check
    run_locally do
      execute :git, 'ls-remote', repo_url, 'HEAD'
    end
  end

  def clone
    config = Capistrano::NetStorage.config

    run_locally do
      if test "[ -f #{config.local_mirror_path}/HEAD ]"
        info t(:mirror_exists, at: config.local_mirror_path)
      else
        execute :git, :clone, '--mirror', repo_url, config.local_mirror_path
      end
    end
  end

  def update
    config = Capistrano::NetStorage.config

    run_locally do
      within config.local_mirror_path do
        execute :git, :remote, :update
      end
    end
  end

  def set_current_revision
    config = Capistrano::NetStorage.config

    run_locally do
      within config.local_mirror_path do
        set :current_revision, capture(:git, "rev-list --max-count=1 #{fetch(:branch)}")
      end
    end
  end

  def prepare_archive
    config = Capistrano::NetStorage.config

    run_locally do
      execute :mkdir, '-p', config.local_release_path

      within config.local_mirror_path do
        if tree = fetch(:repo_tree)
          stripped = tree.slice %r{^/?(.*?)/?$}, 1 # strip both side /
          num_components = stripped.count('/')
          execute(
            :git, :archive, fetch(:branch), tree,
            "| tar -x --strip-components #{num_components} -f - -C ",
            config.local_release_path
          )
        else
          execute :git, :archive, fetch(:branch), '| tar -x -C', config.local_release_path
        end
      end
    end
  end
end
