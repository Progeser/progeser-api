# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Me', type: :request do
  let!(:user)   { users(:user_2) }
  let!(:token)  { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let!(:header) do
    { 'Authorization': "Bearer #{token.token}" }
  end

  let!(:requester)   { users(:user_1) }
  let!(:requester_token)  { Doorkeeper::AccessToken.create!(resource_owner_id: requester.id) }
  let!(:requester_header) do
    { 'Authorization': "Bearer #{requester_token.token}" }
  end

  let!(:invite) { invites(:invite_1) }
  let!(:id)     { invite.id }

  describe 'POST api/v1/invites' do
    context '400' do
      it 'fails to create an invite with missing params' do
        post(
          '/api/v1/invites',
          headers: header,
          params: {
            email: nil,
            role: nil,
            first_name: nil,
            last_name: nil,
            laboratory: nil
          }
        )

        expect(status).to eq(400)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '403' do
      it 'can\'t create an invite as a requester' do
        post('/api/v1/invites', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      it 'fails to create an invite with invalid params' do
        post(
          '/api/v1/invites',
          headers: header,
          params: {
            email: 'foo',
            role: 'foo',
            first_name: 'foo',
            last_name: 'bar',
            laboratory: 'baz'
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'POST api/v1/invites/:id/retry' do
    context '404' do
      it 'can\'t retry sending the invite email as a requester' do
        post("/api/v1/invites/#{id}/retry", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'DELETE api/v1/invites/:id' do
    context '404' do
      it 'can\'t delete an invite as a requester' do
        delete("/api/v1/invites/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      it 'fails to delete an invite' do
        allow_any_instance_of(Invite).to receive(:destroy).and_return(false)

        delete("/api/v1/invites/#{id}", headers: header)

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
