# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Users', type: :request do
  let!(:invite) { invites(:invite_1) }
  let!(:invitation_token) { invite.invitation_token }

  describe 'POST /api/v1/users/:invitation_token/create_from_invite' do
    context '400' do
      it 'fails to create a user with missing params' do
        post(
          "/api/v1/users/#{invitation_token}/create_from_invite",
          params: {
            password: nil,
            password_confirmation: nil
          }
        )

        expect(status).to eq(400)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '404' do
      it 'fails to create a user from invalid invitation_token' do
        post(
          '/api/v1/users/foobar/create_from_invite',
          params: {
            password: 'password',
            password_confirmation: 'password'
          }
        )

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      it 'fails to create a user with different password and password_confirmation' do
        post(
          "/api/v1/users/#{invitation_token}/create_from_invite",
          params: {
            password: 'password',
            password_confirmation: 'PASSWORD'
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end

      it 'rollbacks the user creation if the invite can\'t be destroyed' do
        allow_any_instance_of(Invite).to receive(:destroy).and_return(false)

        post(
          "/api/v1/users/#{invitation_token}/create_from_invite",
          params: {
            password: 'password',
            password_confirmation: 'password'
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank

        invite.reload
        expect(User.find_by(email: invite.email)).to be_nil
      end

      it 'rollbacks the invite deletion & the user creation if the access token can\'t be created' do
        allow(Doorkeeper::AccessToken).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

        post(
          "/api/v1/users/#{invitation_token}/create_from_invite",
          params: {
            password: 'password',
            password_confirmation: 'password'
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank

        invite.reload
        expect(invite).to be_persisted
        expect(User.find_by(email: invite.email)).to be_nil
      end
    end
  end
end
