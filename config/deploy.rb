# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "yuusekai"
set :repo_url, "git@github.com:michaelirick/yuusekai.git"


set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/application.yml', 'config/secrets.yml')

set :passenger_restart_with_touch, true
set :rbenv_type, :user
set :rbenv_ruby, '2.7.1'
set :rbenv_map_bins, %w[rake gem bundle ruby rails]
set :pty, true

# puma config
# set :puma_conf, "#{shared_path}/config/puma.rb"
# set :puma_bind, 'tcp://0.0.0.0:8181'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/yuusekai"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :ssh_options, {
  forward_agent: true,
  auth_methods: %w[publickey],
  keys: %w[~/Downloads/hs01.pem]
}

before "deploy:assets:precompile", "deploy:yarn_install"
namespace :deploy do
  desc "Run rake yarn install"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional")
      end
    end
  end
end


# capistrano-rails config
set :assets_roles, %i[webpack] # Give the webpack role to a single server  
set :assets_prefix, 'packs' # Assets are located in /packs/
set :keep_assets, 10 # Automatically remove stale assets
set :assets_manifests, lambda { # Tell Capistrano-Rails how to find the Webpacker manifests
  [release_path.join('public', fetch(:assets_prefix), 'manifest.json*')]
}

set :conditionally_migrate, true # Only attempt migration if db/migrate changed - not related to Webpacker, but a nice thing
