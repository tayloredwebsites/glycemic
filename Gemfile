source 'https://rubygems.org'
# git_source(:github) do |repo|
#   "https://github.com/#{repo}.git"
# end

ruby '3.3.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails',
  '~> 7.1.3'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg',
  '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma',
  '>= 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis',
  '>= 4.0.1'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Devise install:
gem 'devise',
  '~> 4.8'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
# devise install
gem 'bcrypt',
  '~> 3.1.18'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data',
  platforms: %i[
    mingw windows
  ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap',
  require: false

# Use Sass to process CSS
# gem "sassc-rails"
# see: https://stackoverflow.com/questions/71231622/idiomatic-sass-processing-in-rails-7#71236590
gem 'dartsass-rails',
  '~> 0.4.1'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'smarter_csv',
  '~> 1.7.4'

gem 'rubocop-rails',
  '~> 2.18.0'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug',
    platforms: %i[
      mri mingw x64_mingw
    ]
  # see https://github.com/thoughtbot/factory_bot_rails
  gem 'factory_bot_rails',
    '~> 6.2.0'
  # store authentication_keys safely
  gem 'dotenv-rails',
    '~> 2.8.1'

  # Pry added to fix object doesn't support #inspect in IRB
  gem 'pry-rails', '~> 0.3.9'

  # turn off pager in .pryrc (so pry output in console doesn't stop and give a : prompt)
  # if defined?(PryByebug)
  #   Pry.config.pager = false
  # end
  # breakpoints - put 'binding.pry' line in code to open debugger at that point 
  gem 'pry-byebug', '~> 3.10.1'

  gem 'faker', '~> 3.2.3'

end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'letter_opener',
    '~> 1.8.1'
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
