source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# A PostgreSQL client library for Ruby
gem 'pg', '~> 1.1', '>= 1.1.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# An OAuth 2 provider for Rails and Grape
gem 'doorkeeper', '~> 5.2.0'
gem 'doorkeeper-i18n', '~> 5.2.0'

# Travis CI client
gem 'travis', '~> 1.8', '>= 1.8.8'

# A collection of off-the-shelf and tested ActiveModel/ActiveRecord validations
gem 'activevalidators', '~> 5.1'

# Enumerated attributes with I18n and ActiveRecord/Mongoid support
gem 'enumerize', '~> 2.3'

# Rails authentication with email & password
gem 'clearance', '~> 2.0'

# Minimal authorization through OO design and pure Ruby classes
gem 'pundit', '~> 2.1'

# Optimized JSON
gem 'oj', '~> 3.10'

# Simple, Fast, and Declarative Serialization Library for Ruby
gem 'blueprinter', '~> 0.20'

# Soft deletes for ActiveRecord
gem 'discard', '~> 1.0'

# Mailjet Ruby wrapper
gem 'mailjet', '~> 1.5', '>= 1.5.4'

# Simple, efficient background processing for Ruby
gem 'sidekiq', '~> 6.0', '>= 6.0.3'

# Business Transaction DSL
gem 'dry-transaction', '~> 0.13.0'
# Validation library with type-safe schemas and rules
gem 'dry-validation', '~> 1.3'

# A controller filters engine gem based on jsonapi spec
gem 'fetcheable_on_api', '~> 0.4.1'

# Rack Middleware for handling Cross-Origin Resource Sharing (CORS)
gem 'rack-cors', '~> 1.1'

# An ActiveRecord plugin for managing lists
gem 'acts_as_list', '~> 1.0'

# StateMachines Active Record Integration
gem 'state_machines-activerecord', '~> 0.6.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails', '~> 0.3.9'
  gem 'rspec-rails', '~> 3.8'
  gem 'rspec_api_documentation', '~> 6.1'
  gem 'simplecov', '~> 0.17.1', require: false
  gem 'faker', '~> 2.7'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rubocop', '~> 0.79.0', require: false
  gem 'rubocop-rails', '~> 2.4.0', require: false
  gem 'rubocop-performance', '~> 1.5.0', require: false
  gem 'rubocop-rspec', '~> 1.37.1', require: false
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'annotate', '~> 3.0'
  gem 'rails-erd', '~> 1.6'
end

group :test do
  gem 'database_cleaner'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
