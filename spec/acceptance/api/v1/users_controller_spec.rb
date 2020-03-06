# frozen_string_literal: true

require 'acceptance_helper'

resource 'Users' do
  explanation 'Users resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:invite)           { invites(:invite_1) }
  let!(:invitation_token) { invite.invitation_token }

  let!(:account_request) { account_requests(:account_request_1) }
  let!(:creation_token)  { account_request.creation_token }

  get '/api/v1/users' do
    parameter :'page[number]',
              "The number of the desired page\n\n"\
              "If used, additional information is returned in the response headers:\n"\
              "`Pagination-Current-Page`: the current page number\n"\
              "`Pagination-Per`: the number of records per page\n"\
              "`Pagination-Total-Pages`: the total number of pages\n"\
              '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: 1
    parameter :'page[size]',
              "The number of elements in a page\n\n"\
              "If used, additional information is returned in the response headers:\n"\
              "`Pagination-Current-Page`: the current page number\n"\
              "`Pagination-Per`: the number of records per page\n"\
              "`Pagination-Total-Pages`: the total number of pages\n"\
              '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: FetcheableOnApi.configuration.pagination_default_size

    example 'Get all users' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(User.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(User.count)
    end
  end

  post '/api/v1/users/:invitation_token/create_from_invite' do
    parameter :password, 'Password of the user', with_example: true
    parameter :password_confirmation, 'Password confirmation of the user', with_example: true

    let(:password)              { 'password' }
    let(:password_confirmation) { 'password' }

    let(:raw_post) { params.to_json }

    example 'Create a user from an invite and destroy it' do
      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(User.last.to_blueprint(view: :with_token))

      response = JSON.parse(response_body)
      expect(response.dig('email')).to eq(invite.email)
      expect(response.dig('role')).to eq(invite.role)
      expect(response.dig('first_name')).to eq(invite.first_name)
      expect(response.dig('last_name')).to eq(invite.last_name)
      expect(response.dig('laboratory')).to eq(invite.laboratory)
      expect(response.dig('token', 'access_token')).not_to be_blank
      expect(response.dig('token', 'refresh_token')).not_to be_blank

      expect { invite.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  post '/api/v1/users/:creation_token/create_from_account_request' do
    parameter :laboratory, 'Laboratory of the user', with_example: true
    parameter :password, 'Password of the user', with_example: true
    parameter :password_confirmation, 'Password confirmation of the user', with_example: true

    let(:laboratory)            { 'my laboratory' }
    let(:password)              { 'password' }
    let(:password_confirmation) { 'password' }

    let(:raw_post) { params.to_json }

    example 'Create a user from an account_request and destroy it' do
      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(User.last.to_blueprint(view: :with_token))

      response = JSON.parse(response_body)
      expect(response.dig('email')).to eq(account_request.email)
      expect(response.dig('role')).to eq('requester')
      expect(response.dig('first_name')).to eq(account_request.first_name)
      expect(response.dig('last_name')).to eq(account_request.last_name)
      expect(response.dig('laboratory')).to eq(laboratory)
      expect(response.dig('token', 'access_token')).not_to be_blank
      expect(response.dig('token', 'refresh_token')).not_to be_blank

      expect { account_request.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
