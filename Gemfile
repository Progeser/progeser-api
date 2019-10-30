source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# A PostgreSQL client library for Ruby
gem 'pg', '~> 1.1', '>= 1.1.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# An OAuth 2 provider for Rails and Grape
gem 'doorkeeper', '~> 5.2.0'

# Travis CI client
gem 'travis', '~> 1.8', '>= 1.8.8'

# A collection of off-the-shelf and tested ActiveModel/ActiveRecord validations
gem 'activevalidators', '~> 5.1'

# Enumerated attributes with I18n and ActiveRecord/Mongoid support
gem 'enumerize', '~> 2.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rubocop', '~> 0.75.0', require: false
  gem 'rubocop-rails', '~> 2.3.0'
  gem 'rubocop-performance', '~> 1.5.0'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'annotate'
end

group :test do
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
