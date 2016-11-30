require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module QMeeting
  class Application < Rails::Application
    
   config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        # origins '*'
        # resource '/api/v1/*', :headers => :any, :methods => [:get, :post, :options]
        origins(/http:\/\/localhost:(\d*)/,
                /^(http|https):\/\/.*\.meetings\.qwinixtech\.com/
               )
        resource '/api/v1/*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
      end
    end
    config.active_record.raise_in_transactional_callbacks = true
  end
end
