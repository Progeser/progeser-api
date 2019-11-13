# frozen_string_literal: true

require 'acceptance_helper'

resource 'Account Requests' do
  explanation 'Account Requests resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

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
end
