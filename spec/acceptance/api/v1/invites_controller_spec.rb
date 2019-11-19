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

    example 'Creating an invite and send an email' do
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
    example 'Deleting an invite' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)
      
      expect{invite.reload}.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
