# frozen_string_literal: true

RSpec.shared_context 'without authentication' do
  let(:user) { users(:user1) }
  let(:application) { oauth_applications(:application) }
  let(:token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id, application:) }
end

RSpec.shared_context 'with authenticated grower' do
  let(:user) { users(:user2) }
  let(:application) { oauth_applications(:application) }
  let(:token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id, application:) }
  let(:headers) do
    { Authorization: "Bearer #{token.token}" }
  end
end
