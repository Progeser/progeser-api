# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Users', type: :request do
  describe 'GET api/v1/users' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets users with pagination params' do
          get(
            '/api/v1/users',
            headers: headers,
            params: {
              page: {
                number: 1,
                size: 2
              }
            }
          )

          expect(status).to eq(200)

          expect(response.parsed_body.count).to eq(2)
          expect(response.headers.dig('Pagination-Current-Page')).to eq(1)
          expect(response.headers.dig('Pagination-Per')).to eq(2)
          expect(response.headers.dig('Pagination-Total-Pages')).to eq(2)
          expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
        end
      end

      it_behaves_like 'with authenticated requester' do
        it 'gets the authenticated user only' do
          get('/api/v1/users', headers: headers)

          expect(status).to eq(200)

          expect(response.parsed_body.count).to eq(1)
          expect(response.parsed_body.first.dig('id')).to eq(user.id)
        end
      end
    end
  end

  describe 'POST /api/v1/users/:invitation_token/create_from_invite' do
    let!(:invite)           { invites(:invite_1) }
    let!(:invitation_token) { invite.invitation_token }

    context 'when 400' do
      it 'fails to create a user with missing params' do
        post(
          "/api/v1/users/#{invitation_token}/create_from_invite",
          params: {
            password: '',
            password_confirmation: ''
          }
        )

        expect(status).to eq(400)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 404' do
      it 'fails to create a user from invalid invitation_token' do
        post('/api/v1/users/foobar/create_from_invite')

        expect(status).to eq(404)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to create a user with different password and password_confirmation' do
        post(
          "/api/v1/users/#{invitation_token}/create_from_invite",
          params: {
            password: 'password',
            password_confirmation: 'PASSWORD'
          }
        )

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
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
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank

        invite.reload
        expect(User.find_by(email: invite.email)).to be_nil
      end

      it 'rollbacks the invite deletion '\
      '& the user creation if the access token can\'t be created' do
        allow(Doorkeeper::AccessToken).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

        post(
          "/api/v1/users/#{invitation_token}/create_from_invite",
          params: {
            password: 'password',
            password_confirmation: 'password'
          }
        )

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank

        invite.reload
        expect(invite).to be_persisted
        expect(User.find_by(email: invite.email)).to be_nil
      end
    end
  end

  describe 'POST /api/v1/users/:invitation_token/create_from_account_request' do
    let!(:account_request) { account_requests(:account_request_1) }
    let!(:creation_token)  { account_request.creation_token }

    context 'when 400' do
      it 'fails to create a user with missing params' do
        post(
          "/api/v1/users/#{creation_token}/create_from_account_request",
          params: {
            laboratory: '',
            password: 'password',
            password_confirmation: 'password'
          }
        )

        expect(status).to eq(400)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 403' do
      let!(:account_request) { account_requests(:account_request_2) }
      let!(:creation_token)  { account_request.creation_token }

      it 'can\'t create a user from unaccepted account_request' do
        post("/api/v1/users/#{creation_token}/create_from_account_request")

        expect(status).to eq(403)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 404' do
      it 'fails to create a user from invalid creation_token' do
        post('/api/v1/users/foobar/create_from_account_request')

        expect(status).to eq(404)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to create a user with different password and password_confirmation' do
        post(
          "/api/v1/users/#{creation_token}/create_from_account_request",
          params: {
            laboratory: 'my laboratory',
            password: 'password',
            password_confirmation: 'PASSWORD'
          }
        )

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end

      it 'rollbacks the user creation if the account_request can\'t be destroyed' do
        allow_any_instance_of(AccountRequest).to receive(:destroy).and_return(false)

        post(
          "/api/v1/users/#{creation_token}/create_from_account_request",
          params: {
            laboratory: 'my laboratory',
            password: 'password',
            password_confirmation: 'password'
          }
        )

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank

        account_request.reload
        expect(User.find_by(email: account_request.email)).to be_nil
      end

      it 'rollbacks the account request deletion '\
      '& the user creation if the access token can\'t be created' do
        allow(Doorkeeper::AccessToken).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

        post(
          "/api/v1/users/#{creation_token}/create_from_account_request",
          params: {
            laboratory: 'my laboratory',
            password: 'password',
            password_confirmation: 'password'
          }
        )

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank

        account_request.reload
        expect(account_request).to be_persisted
        expect(User.find_by(email: account_request.email)).to be_nil
      end
    end
  end
end
