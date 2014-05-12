set :application, 'grid3'
set :repo_url, 'git@github.com:vojto/grid3.git'
set :branch, 'manual'
set :scm, :git
set :deploy_to, '/var/apps/grid3'
set :user, 'vojto'
set :use_sudo, false
set :normalize_asset_timestamps, false
set :shared_children, %w(log public)
set :meteor, 'mrt'
set :pty, true

# Upload directory
# set :linked_dirs, %w{public/photos}

set :default_env, {
  :root_url => "http://grid3.co",
  :mongo_url => "mongodb://localhost/grid3",
  :port => "8014",
  :public_path => "#{fetch(:deploy_to)}/current/public"
}
set :keep_releases, 5

namespace :deploy do
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute "pm2", "sendSignal", "SIGKILL", fetch(:application)
        execute "pm2", "delete", fetch(:application)
        execute "pm2", "start", "#{current_path}/bundle/main.js", "-n", fetch(:application)
      end
    end
  end
end

after 'deploy:updated', :meteor_bundle do
  on roles(:app), in: :sequence, wait: 5 do
    execute "cd #{release_path}; #{fetch(:meteor)} update"
    execute "cd #{release_path}; #{fetch(:meteor)} bundle bundle.tgz"
    execute "cd #{release_path}; tar xvf #{File.join(release_path, "bundle.tgz")}"
    execute "rm -rf #{File.join(release_path, "bundle.tgz")}"
  end
end

after 'deploy:publishing', 'deploy:restart'