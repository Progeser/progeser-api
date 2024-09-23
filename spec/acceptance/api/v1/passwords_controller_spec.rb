# frozen_string_literal: true

require 'acceptance_helper'

resource 'Passwords' do
  explanation 'Passwords resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user1) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  post '/api/v1/passwords/forgot' do
    parameter :email, 'Email associated to the forgotten password', with_example: true

    let(:email)    { user.email }
    let(:raw_post) { params.to_json }

    before { allow(Mailjet::Send).to receive(:create).and_return(nil) }

    example 'Send an email to reset user password' do
      do_request

      expect(status).to eq(204)

      expect(Mailjet::Send).to have_received(:create).once
    end
  end

  put '/api/v1/passwords/:confirmation_token/reset' do
    let(:confirmation_token) { user.confirmation_token }

    before do
      user.forgot_password!
    end

    parameter :password, 'The new password', with_example: true
    parameter :password_confirmation, 'Confirmation of the new password', with_example: true

    let(:password)              { 'foobar' }
    let(:password_confirmation) { 'foobar' }

    let(:raw_post) { params.to_json }

    example 'Set new password' do
      expect(user.authenticated?('password')).to be(true)

      do_request

      expect(status).to eq(200)

      user.reload
      expect(user.authenticated?('foobar')).to be(true)
      expect(response_body).to eq(user.to_blueprint(view: :with_token))

      response = JSON.parse(response_body)
      expect(response.dig('token', 'access_token')).not_to be_blank
      expect(response.dig('token', 'refresh_token')).not_to be_blank
      expect(user.reload.confirmation_token).to be_nil
    end
  end

  put '/api/v1/passwords' do
    parameter :current_password, 'The current password', with_example: true
    parameter :password, 'The new password', with_example: true
    parameter :password_confirmation, 'Confirmation of the new password', with_example: true

    let(:current_password)      { 'password' }
    let(:password)              { 'newPassword' }
    let(:password_confirmation) { 'newPassword' }

    let(:raw_post) { params.to_json }

    example 'Update password for current user' do
      authentication :basic, "Bearer #{user_token.token}"

      expect(user.authenticated?('newPassword')).to be(false)

      do_request

      expect(status).to eq(204)
      user.reload
      expect(user.authenticated?('newPassword')).to be(true)
    end
  end
end
