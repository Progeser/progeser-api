# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Passwords', type: :request do
  let!(:user) { users(:user_1) }
  let!(:token)  { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let!(:header) do
    { 'Authorization': "Bearer #{token.token}" }
  end

  describe 'POST /api/v1/passwords/forgot' do
    context 'when 404' do
      it 'can\'t find a user with wrong email' do
        post(
          '/api/v1/passwords/forgot',
          params: {
            email: 'foo@bar.com'
          }
        )

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to call `forgot_password!` and generate a new confirmation_token' do
        allow_any_instance_of(User).to receive(:forgot_password!).and_return(false)

        post(
          '/api/v1/passwords/forgot',
          params: {
            email: user.email
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'PUT /api/v1/passwords/:confirmation_token/reset' do
    context 'when 400' do
      before do
        user.forgot_password!
      end

      it 'fails to reset password with missing params' do
        put(
          "/api/v1/passwords/#{user.confirmation_token}/reset",
          params: {
            password: '',
            password_confirmation: ''
          }
        )

        expect(status).to eq(400)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 404' do
      it 'can\'t find a user with wrong confirmation_token' do
        put('/api/v1/passwords/foobar/reset')

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      before do
        user.forgot_password!
      end

      it 'fails to reset password if confirmation doesn\'t match' do
        put(
          "/api/v1/passwords/#{user.confirmation_token}/reset",
          params: {
            confirmation_token: user.confirmation_token,
            password: 'newPassword',
            password_confirmation: 'foobar'
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end

      it 'rollbacks the password reset if the access token can\'t be created' do
        allow(Doorkeeper::AccessToken).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

        put(
          "/api/v1/passwords/#{user.confirmation_token}/reset",
          params: {
            confirmation_token: user.confirmation_token,
            password: 'newPassword',
            password_confirmation: 'newPassword'
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank

        user.reload
        expect(user.confirmation_token).not_to be_nil
        expect(user.authenticated?('password')).to eq(true)
        expect(user.authenticated?('newPassword')).to eq(false)
      end
    end
  end

  describe 'PUT /api/v1/passwords' do
    context 'when 400' do
      it 'fails to update password with missing params' do
        put(
          '/api/v1/passwords/',
          headers: header,
          params: {
            current_password: 'password',
            password: '',
            password_confirmation: ''
          }
        )

        expect(status).to eq(400)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 403' do
      it 'can\'t update password with invalid current password' do
        put(
          '/api/v1/passwords',
          headers: header,
          params: {
            current_password: 'foobar'
          }
        )

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to update password if confirmation doesn\'t match' do
        put(
          '/api/v1/passwords',
          headers: header,
          params: {
            current_password: 'password',
            password: 'newPassword',
            password_confirmation: 'foobar'
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
