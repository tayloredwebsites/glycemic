require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Glycemic
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # add rubocop disables to rails notes
    config.annotations.register_tags('rubocop:disable')

    # turn off pry in rails console (IRB=true rails console)
    # https://stackoverflow.com/questions/25145937/how-to-i-start-a-rails-console-with-pry-turned-off#32130014
    console do
      if ENV['IRB']
        require 'irb'
        config.console = IRB
      end
    end
    
  end
end
