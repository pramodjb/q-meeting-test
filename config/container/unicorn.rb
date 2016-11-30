# set path to application
app_dir = "/rails_app"
# shared_dir = "#{app_dir}/shared"
working_directory app_dir


# Set unicorn options
worker_processes 1
timeout 30

# Set up socket location
listen "/tmp/unicorn.sock", :backlog => 64

# Logging
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "/tmp/unicorn.pid"
