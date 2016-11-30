#!/bin/bash
truncate -s 0 /tmp/unicorn.pid
core = ENV['cpu_cores'] || 4
bundle check || bundle install -j cores
bundle exec rake assets:precompile
bundle exec unicorn -c config/container/unicorn.rb -D
service nginx restart
