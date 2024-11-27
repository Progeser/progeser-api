# frozen_string_literal: true

class Api::V1::UsersController < ApiController

  def index
    users = policy_scope(User)
    authorize users
    render json: apply_fetcheable(users).to_blueprint
  end
end
