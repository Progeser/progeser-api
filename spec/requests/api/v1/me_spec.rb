# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Me', type: :request do
  include_context 'with authenticated grower'

  describe 'GET api/v1/me' do
    context 'when 404' do
      let!(:discarded_user) { users(:user3) }
      let!(:discarded_user_token) do
        Doorkeeper::AccessToken.create!(resource_owner_id: discarded_user.id)
      end
      let!(:discarded_user_headers) do
        { Authorization: "Bearer #{discarded_user_token.token}" }
      end

      it 'can\'t get a discarded user' do
        get('/api/v1/me', headers: discarded_user_headers)

        expect(status).to eq(404)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'PUT api/v1/me' do
    context 'when 200' do
      it 'can\'t update `laboratory` param for a grower' do
        put(
          '/api/v1/me',
          headers:,
          params: {
            first_name: 'my new first name',
            last_name: 'my new last name',
            laboratory: 'laboratory'
          }
        )

        expect(status).to eq(200)

        user.reload
        expect(response.body).to eq(user.to_blueprint)
        expect(user.first_name).to eq('my new first name')
        expect(user.last_name).to eq('my new last name')
        expect(user.laboratory).to be_nil
      end
    end

    context 'when 422' do
      it 'fails to update user' do
        allow_any_instance_of(User).to receive(:update).and_return(false)

        put('/api/v1/me', headers:)

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'DELETE api/v1/me' do
    context 'when 422' do
      it 'fails to soft delete user' do
        allow_any_instance_of(User).to receive(:discard).and_return(false)

        delete('/api/v1/me', headers:)

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end
  end
end
