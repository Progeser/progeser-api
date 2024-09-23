# frozen_string_literal: true

require 'acceptance_helper'

resource 'Invites' do
  explanation 'Invites resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:invite)           { invites(:invite1) }
  let!(:id)               { invite.id }
  let!(:invitation_token) { invite.invitation_token }

  get '/api/v1/invites' do
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

    example 'Get all invites' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(Invite.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Invite.count)
    end
  end

  get '/api/v1/invites/:id' do
    example 'Get an invite' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(invite.to_blueprint)
    end
  end

  get '/api/v1/invites/token/:invitation_token' do
    example 'Get an invite from its invitation_token' do
      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(invite.to_blueprint)
    end
  end

  post '/api/v1/invites' do
    parameter :email, 'Email of the user to invite', with_example: true
    parameter :role, 'Role of the user to invite', with_example: true, enum: %w[grower requester]
    parameter :first_name, 'First name of the user to invite', with_example: true
    parameter :last_name, 'Last name of the user to invite', with_example: true
    parameter :laboratory,
              'Laboratory of the user to invite (only for a requester)',
              with_example: true

    let(:email)      { 'requester_to_invite@progeser.com' }
    let(:role)       { 'requester' }
    let(:first_name) { 'invite first name' }
    let(:last_name)  { 'invite last name' }
    let(:laboratory) { 'invite laboratory' }

    let(:raw_post) { params.to_json }

    before { allow(Mailjet::Send).to receive(:create).and_return(nil) }

    example 'Create an invite and send an email' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(Mailjet::Send).to have_received(:create).once

      response = JSON.parse(response_body)
      expect(response['email']).to eq(email)
      expect(response['role']).to eq(role)
      expect(response['first_name']).to eq(first_name)
      expect(response['last_name']).to eq(last_name)
      expect(response['laboratory']).to eq(laboratory)
    end
  end

  post '/api/v1/invites/:id/retry' do
    before { allow(Mailjet::Send).to receive(:create).and_return(nil) }

    example 'Retry sending the invite email' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect(Mailjet::Send).to have_received(:create).once
    end
  end

  delete '/api/v1/invites/:id' do
    example 'Delete an invite' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { invite.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
