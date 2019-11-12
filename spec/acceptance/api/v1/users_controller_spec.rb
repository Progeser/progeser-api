# frozen_string_literal: true

require 'acceptance_helper'

resource 'Users' do
  explanation 'Users resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:invite)           { invites(:invite_1) }
  let!(:invitation_token) { invite.invitation_token }

  post '/api/v1/users/:invitation_token/create_from_invite' do
    parameter :password, 'Password of the user',  with_example: true
    parameter :password_confirmation, 'Password confirmation of the user', with_example: true

    let(:password)  { 'password' }
    let(:password_confirmation) { 'password' }

    let(:raw_post) { params.to_json }

    example 'Creating a user from an invite and destroy it' do
      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(User.last.to_blueprint)
      expect(JSON.parse(response_body).dig('email')).to eq(invite.email)
      expect(JSON.parse(response_body).dig('role')).to eq(invite.role)
      expect(JSON.parse(response_body).dig('first_name')).to eq(invite.first_name)
      expect(JSON.parse(response_body).dig('last_name')).to eq(invite.last_name)
      expect(JSON.parse(response_body).dig('laboratory')).to eq(invite.laboratory)
      
      expect{invite.reload}.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
