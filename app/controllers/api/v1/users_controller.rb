# frozen_string_literal: true

class Api::V1::UsersController < ApiController
  def index
    users = policy_scope(User).kept
    authorize users
    render json: apply_fetcheable(users).to_blueprint
  end

  def show
    user = policy_scope(User).find(params[:id])
    authorize user
    render json: user.to_blueprint
  end

  def create
    user = User.new(create_params)

    authorize user

    if user.save
      render json: user.to_blueprint, status: :created
    else
      render_validation_error(user)
    end
  end

  def destroy
    user = policy_scope(User).kept.find(params[:id])
    authorize user

    if current_user.discard
      head :no_content
    else
      render_validation_error(user)
    end
  end

  private

  def create_params
    params.permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end
end
