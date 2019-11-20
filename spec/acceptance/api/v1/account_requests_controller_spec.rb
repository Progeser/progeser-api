# frozen_string_literal: true

require 'acceptance_helper'

resource 'Account Requests' do
  explanation 'Account Requests resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:account_request) { account_requests(:account_request_1) }
  let!(:id)              { account_request.id }

  post '/api/v1/account_requests' do
    parameter :email, 'Email of the requested account', with_example: true
    parameter :first_name, 'First name of the requested account', with_example: true
    parameter :last_name, 'Last name of the requested account',  with_example: true
    parameter :comment, '(Optional) Free comment to give additional information', with_example: true

    let(:email)      { Faker::Internet.email }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name)  { Faker::Name.last_name }
    let(:comment)    { Faker::Movies::VForVendetta.speech }

    let(:raw_post) { params.to_json }

    example 'Creating an account request' do
      do_request

      expect(status).to eq(201)

      response = JSON.parse(response_body)
      expect(response.dig('email')).to eq(email)
      expect(response.dig('first_name')).to eq(first_name)
      expect(response.dig('last_name')).to eq(last_name)
      expect(response.dig('comment')).to eq(comment)
    end
  end

  post '/api/v1/account_requests/:id/accept' do
    example 'Accepting an account request and send an email' do
      authentication :basic, "Bearer #{user_token.token}"

      allow_any_instance_of(ApplicationMailer).to receive(:send_mail).and_return(false)

      do_request

      expect(status).to eq(200)

      account_request.reload
      expect(JSON.parse(response_body).dig('accepted')).to eq(true)
      expect(account_request.accepted).to eq(true)
    end
  end

  delete '/api/v1/account_requests/:id' do
    example 'Refusing an account request and delete it' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect{account_request.reload}.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
