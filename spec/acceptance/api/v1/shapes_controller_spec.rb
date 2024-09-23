# frozen_string_literal: true

require 'acceptance_helper'

resource 'Shapes' do
  explanation 'Shapes resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  get '/api/v1/shapes' do
    example 'Get all shapes' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(Shape.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Shape.descendants.count)
    end
  end
end
