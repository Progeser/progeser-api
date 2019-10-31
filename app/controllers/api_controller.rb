# frozen_string_literal: true

class ApiController < ActionController::API
  # Doorkeeper
  before_action :doorkeeper_authorize!

  # Pundit
  include Pundit
  after_action :verify_authorized
  after_action :verify_policy_scoped

  protected

  def current_user
    return if doorkeeper_token.blank?

    @current_user = User.find(doorkeeper_token.resource_owner_id)
  end

  def render_error(model_or_message, code: 400)
    error = {
      error: {
        code: code,
        status: Rack::Utils::HTTP_STATUS_CODES[code]
      }
    }

    error[:error].merge!(error_messages_and_details(model_or_message))

    Rails.logger.warn(error)
    render json: error, status: code
  end

  def error_messages_and_details(model_or_message)
    if model_or_message.is_a?(ActiveRecord::Base)
      model = model_or_message
      return { messages: model.errors.messages, details: model.errors.details }
    end

    message = model_or_message
    { message: [message].flatten }
  end

  def render_validation_error(model)
    model.errors.add(:validate, message: 'an unknown error occured') if model.errors.empty?

    render_error(model, code: 422)
  end
end
