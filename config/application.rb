require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProgeserApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # URLs
    Rails.application.routes.default_url_options = {host: ENV['BASE_URL']}
    config.default_url_options = {host: ENV['BASE_URL']}
    config.action_mailer.default_url_options = {host: ENV['BASE_URL']}

    # I18n
    I18n.config.available_locales = %i[fr en]
    config.i18n.default_locale = :fr
  end
end
