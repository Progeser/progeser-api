# frozen_string_literal: true

require 'acceptance_helper'

resource 'Invites' do
  explanation 'Invites resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:invite) { invites(:invite_1) }
  let!(:id)     { invite.id }

  get '/api/v1/invites' do
    with_options scope: :page, with_example: true do
      parameter :number,
                "The number of the desired page (must be called in `page` scope)\n\n"\
                "If used, additional information is returned in the response headers:\n"\
                "`Pagination-Current-Page`: the current page number\n"\
                "`Pagination-Per`: the number of records per page\n"\
                "`Pagination-Total-Pages`: the total number of pages\n"\
                '`Pagination-Total-Count`: the total number of records',
                type: :integer
      parameter :size,
                'The number of elements in a page (must be called in `page` scope)',
                type: :integer,
                default: FetcheableOnApi.configuration.pagination_default_size
    end

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

  post '/api/v1/invites' do
    parameter :email, 'Email of the user to invite', with_example: true
    parameter :role, 'Role of the user to invite', with_example: true, enum: %w[grower requester]
    parameter :first_name, 'First name of the user to invite', with_example: true
    parameter :last_name, 'Last name of the user to invite',  with_example: true
    parameter :laboratory, 'Laboratory of the user to invite (only for a requester)', with_example: true

    let(:email)      { 'requester_to_invite@progeser.com' }
    let(:role)       { 'requester' }
    let(:first_name) { 'invite first name' }
    let(:last_name)  { 'invite last name' }
    let(:laboratory) { 'invite laboratory' }

    let(:raw_post) { params.to_json }

    example 'Create an invite and send an email' do
      authentication :basic, "Bearer #{user_token.token}"

      allow_any_instance_of(ApplicationMailer).to receive(:send_mail).and_return(false)

      do_request

      expect(status).to eq(201)

      response = JSON.parse(response_body)
      expect(response.dig('email')).to eq(email)
      expect(response.dig('role')).to eq(role)
      expect(response.dig('first_name')).to eq(first_name)
      expect(response.dig('last_name')).to eq(last_name)
      expect(response.dig('laboratory')).to eq(laboratory)
    end
  end

  post '/api/v1/invites/:id/retry' do
    example 'Retry sending the invite email' do
      authentication :basic, "Bearer #{user_token.token}"

      allow_any_instance_of(ApplicationMailer).to receive(:send_mail).and_return(false)

      do_request

      expect(status).to eq(204)
    end
  end

  delete '/api/v1/invites/:id' do
    example 'Delete an invite' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)
      
      expect{invite.reload}.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
