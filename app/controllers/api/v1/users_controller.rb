# frozen_string_literal: true

class Api::V1::UsersController < ApiController
  def index
    users = policy_scope(User)
    authorize users
    render json: apply_fetcheable(users).to_blueprint
  end

  def show
    user = policy_scope(User).find(params[:id])
    authorize user
    render json: user.to_blueprint
  end

  def create
    user_params = create_params
    user = User.new(user_params)

    authorize user

    if user.save
      render json: user.to_blueprint, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = policy_scope(User).find(params[:id])
    authorize user

    if user.destroy
      render json: { message: 'User deleted' }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end
end
