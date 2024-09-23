# frozen_string_literal: true

require 'oj'

Blueprinter.configure do |config|
  Oj::Rails.mimic_JSON
  config.generator = Oj
end
