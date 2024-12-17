# frozen_string_literal: true

require 'acceptance_helper'

resource 'Me' do
  explanation 'Me resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { users(:user1) }
  let!(:user_last_name) { user.last_name }
  let!(:user_first_name) { user.first_name }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  get '/api/v1/me' do
    example 'Get current user informations' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(user.to_blueprint)
    end
  end

  put '/api/v1/me' do
    parameter :first_name, 'The new first name', with_example: true
    parameter :last_name,  'The new last name',  with_example: true
    parameter :laboratory, 'The new laboratory (only for a requester)', with_example: true

    let(:first_name) { 'Updated first name' }
    let(:last_name)  { 'Updated last name' }
    let(:laboratory) { 'Updated laboratory' }

    let(:raw_post) { params.to_json }

    example 'Update current user' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      user.reload
      expect(response_body).to eq(user.to_blueprint)
      expect(user.first_name).to eq(first_name)
      expect(user.last_name).to eq(last_name)
    end
  end

  delete '/api/v1/me' do
    example 'Soft delete current user & anonymize his data' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      user.reload
      expect(user.discarded?).to be(true)
      expect(user.email).to eq('anonymized_1')
      expect(user.encrypted_password).to eq('anonymized')
      expect(user.first_name).to eq(user_first_name)
      expect(user.last_name).to eq(user_last_name)
    end
  end
end
