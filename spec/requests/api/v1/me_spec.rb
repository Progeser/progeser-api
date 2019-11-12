# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Me', type: :request do
  let!(:user)   { users(:user_2) }
  let!(:token)  { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let!(:header) do
    { 'Authorization': "Bearer #{token.token}" }
  end

  describe 'GET api/v1/me' do
    context '404' do
      let!(:discarded_user) { users(:user_3) }
      let!(:discarded_user_token)  do
        Doorkeeper::AccessToken.create!(resource_owner_id: discarded_user.id)
      end
      let!(:discarded_user_header) do
        { 'Authorization': "Bearer #{discarded_user_token.token}" }
      end

      it 'can\'t get a discarded user' do
        get('/api/v1/me', headers: discarded_user_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'PUT api/v1/me' do
    context '200' do
      it 'can\'t update `laboratory` param for a grower' do
        put(
          '/api/v1/me',
          headers: header,
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

    context '422' do
      it 'fails to update user' do
        allow_any_instance_of(User).to receive(:update).and_return(false)

        put('/api/v1/me', headers: header)

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'DELETE api/v1/me' do
    it 'fails to soft delete user' do
      allow_any_instance_of(User).to receive(:discard).and_return(false)

      delete('/api/v1/me', headers: header)

      expect(status).to eq(422)
      expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
    end
  end
end
