# frozen_string_literal: true

require 'acceptance_helper'

resource 'Passwords' do
  explanation 'Passwords resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user1) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

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
