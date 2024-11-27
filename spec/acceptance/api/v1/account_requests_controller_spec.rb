# frozen_string_literal: true

require 'acceptance_helper'

resource 'Account Requests' do
  explanation 'Account Requests resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:account_request) { account_requests(:account_request1) }
  let!(:id)              { account_request.id }

  get '/api/v1/account_requests' do
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

    example 'Get all account requests' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(AccountRequest.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(AccountRequest.count)
    end
  end

  get '/api/v1/account_requests/pending_account_requests_count' do
    example 'Get number of pending account requests' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(
        JSON.parse(response_body)['pending_account_requests_count']
      ).to eq(AccountRequest.where(accepted: false).count)
    end
  end

  get '/api/v1/account_requests/:id' do
    example 'Get an account request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(account_request.to_blueprint)
    end
  end

  post '/api/v1/account_requests' do
    parameter :email, 'Email of the requested account', with_example: true
    parameter :first_name, 'First name of the requested account', with_example: true
    parameter :last_name, 'Last name of the requested account', with_example: true
    parameter :comment, '(Optional) Free comment to give additional information', with_example: true
    parameter :laboratory, '(Optional) Laboratory of the requested account', with_example: true
    parameter :password, 'Password of the requested account', with_example: true

    let(:email)      { Faker::Internet.email }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name)  { Faker::Name.last_name }
    let(:comment)    { Faker::Movies::VForVendetta.speech }
    let(:laboratory) { Faker::Company.name }
    let(:password)   { Faker::Internet.password }

    let(:raw_post) { params.to_json }

    example 'Create an account request' do
      do_request

      expect(status).to eq(201)

      response = JSON.parse(response_body)
      expect(response['email']).to eq(email)
      expect(response['first_name']).to eq(first_name)
      expect(response['last_name']).to eq(last_name)
      expect(response['comment']).to eq(comment)
      expect(response['laboratory']).to eq(laboratory)
      expect(response).not_to have_key('password_digest')
    end
  end

  post '/api/v1/account_requests/:id/accept' do
    example 'Accept an account request and create a user' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      account_request.reload
      expect(account_request.accepted).to be(true)
    end
  end

  delete '/api/v1/account_requests/:id' do
    example 'Refuse an account request and delete it' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { account_request.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
