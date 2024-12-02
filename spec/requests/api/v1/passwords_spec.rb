# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Passwords', type: :request do
  include_context 'with authenticated grower'

  describe 'PUT /api/v1/passwords' do
    context 'when 400' do
      it 'fails to update password with missing params' do
        put(
          '/api/v1/passwords/',
          headers:,
          params: {
            current_password: 'password',
            password: '',
            password_confirmation: ''
          }
        )

        expect(status).to eq(400)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 403' do
      it 'can\'t update password with invalid current password' do
        put(
          '/api/v1/passwords',
          headers:,
          params: {
            current_password: 'foobar'
          }
        )

        expect(status).to eq(403)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to update password if confirmation doesn\'t match' do
        put(
          '/api/v1/passwords',
          headers:,
          params: {
            current_password: 'password',
            password: 'newPassword',
            password_confirmation: 'foobar'
          }
        )

        expect(status).to eq(422)
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end
  end
end
