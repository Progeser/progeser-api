source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2.1.1'
# Use Puma as the app server
gem 'puma', '~> 6.4'
# A PostgreSQL client library for Ruby
gem 'pg', '~> 1.1'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# An OAuth 2 provider for Rails and Grape
gem 'doorkeeper', '~> 5.7'
gem 'doorkeeper-i18n', '~> 5.2'

# Enumerated attributes with I18n and ActiveRecord/Mongoid support
gem 'enumerize', '~> 2.3'

# Rails authentication with email & password
gem 'clearance', '~> 2.5'

# Minimal authorization through OO design and pure Ruby classes
gem 'pundit', '~> 2.1'

# Optimized JSON
gem 'oj', '~> 3.10'

# Simple, Fast, and Declarative Serialization Library for Ruby
gem 'blueprinter'

# Soft deletes for ActiveRecord
gem 'discard'

# Mailjet Ruby wrapper
gem 'mailjet', '~> 1.5', '>= 1.5.4'

# Simple, efficient background processing for Ruby
gem 'sidekiq', '~> 6.2'

# Business Transaction DSL
gem 'dry-transaction'
# Validation library with type-safe schemas and rules
gem 'dry-validation'

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
  gem 'rspec-rails'
  gem 'rspec_api_documentation', '~> 6.1'
  gem 'simplecov', require: false
  gem 'simplecov-json', require: false
  gem 'faker', '~> 2.7'
end

group :development do
  gem 'listen'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
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
