set :stage, :production
set :branch, :master
set :deploy_to, '/u01/apps/qwinix/q-meeting'
set :log_level, :debug

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
role :app, %w{deploy@52.88.157.184}
role :web, %w{deploy@52.88.157.184}
role :db, %w{deploy@52.88.157.184}
server '52.88.157.184', roles: %w{:web, :app, :db}, user: 'deploy'

set :ssh_options, {
   #verbose: :debug,
   keys: %w(~/.ssh/id_rsa),
   auth_methods: %w(publickey)
}