# frozen_string_literal: true

require 'acceptance_helper'

resource 'Users' do
  explanation 'Users resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  get '/api/v1/users' do
    parameter :'page[number]',
              "The number of the desired page\n\n" \
              "If used, additional information is returned in the response headers:\n" \
              "`Pagination-Current-Page`: the current page number\n" \
              "`Pagination-Per`: the number of records per page\n" \
              "`Pagination-Total-Pages`: the total number of pages\n" \
              '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: 1
    parameter :'page[size]',
              "The number of elements in a page\n\n" \
              "If used, additional information is returned in the response headers:\n" \
              "`Pagination-Current-Page`: the current page number\n" \
              "`Pagination-Per`: the number of records per page\n" \
              "`Pagination-Total-Pages`: the total number of pages\n" \
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

  get '/api/v1/users/:id' do
    parameter :id, 'The user id', with_example: true, type: :integer

    let(:id) { user.id }

    example 'Get a user' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(JSON.parse(response_body)['id']).to eq(user.id)
      expect(JSON.parse(response_body)['email']).to eq(user.email)
      expect(JSON.parse(response_body)['first_name']).to eq(user.first_name)
      expect(JSON.parse(response_body)['last_name']).to eq(user.last_name)
    end
  end

  post '/api/v1/users' do
    parameter :email, 'The user email', with_example: true
    parameter :first_name, 'The user first name', with_example: true
    parameter :last_name, 'The user last name', with_example: true
    parameter :password, 'The user password', with_example: true
    parameter :password_confirmation, 'The user password confirmation', with_example: true

    let(:email)      { 'test@test.com' }
    let(:first_name) { 'Test' }
    let(:last_name)  { 'User' }
    let(:password)   { 'password' }
    let(:password_confirmation) { 'password' }

    let(:raw_post) { params.to_json }

    example 'Create a user' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)
      expect(JSON.parse(response_body)['email']).to eq(email)
      expect(JSON.parse(response_body)['first_name']).to eq(first_name)
      expect(JSON.parse(response_body)['last_name']).to eq(last_name)
    end
  end

  delete '/api/v1/users/:id' do
    parameter :id, 'The user id', with_example: true, type: :integer

    let(:id) { user.id }

    example 'Delete a user' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(JSON.parse(response_body)['message']).to eq('User deleted')
    end
  end
end
