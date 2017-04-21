require 'capistrano/net_storage/scm/base'

# Internal SCM class for Git repository
class Capistrano::NetStorage::SCM::Git < Capistrano::NetStorage::SCM::Base
  def check
    run_locally do
      execute :git, 'ls-remote', repo_url, 'HEAD'
    end
  end

  def clone
    c = config
    run_locally do
      if File.exist?("#{c.local_mirror_path}/HEAD")
        info t(:mirror_exists, at: c.local_mirror_path)
      else
        execute :git, :clone, '--mirror', repo_url, c.local_mirror_path
      end
    end
  end

  def update
    c = config
    run_locally do
      within c.local_mirror_path do
        execute :git, :remote, :update
      end
    end
  end

  def set_current_revision
    return if fetch(:current_revision)
    c = config
    run_locally do
      within c.local_mirror_path do
        set :current_revision, capture(:git, "rev-parse #{fetch(:branch)}")
      end
    end
  end

  def prepare_archive
    c = config
    run_locally do
      execute :mkdir, '-p', c.local_release_path

      within c.local_mirror_path do
        if tree = fetch(:repo_tree)
          stripped = tree.slice %r{^/?(.*?)/?$}, 1 # strip both side /
          num_components = stripped.count('/')
          execute(
            :git, :archive, fetch(:branch), tree,
            "| tar -x --strip-components #{num_components} -f - -C ",
            c.local_release_path
          )
        else
          execute :git, :archive, fetch(:branch), '| tar -x -C', c.local_release_path
        end
      end
    end
  end
end
