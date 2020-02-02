# frozen_string_literal: true

RSpec.shared_context 'with authenticated requester' do
  let(:user)  { users(:user_1) }
  let(:token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let(:headers) do
    {
      'Authorization': "Bearer #{token.token}"
    }
  end
end

RSpec.shared_context 'with authenticated grower' do
  let(:user)  { users(:user_2) }
  let(:token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let(:headers) do
    {
      'Authorization': "Bearer #{token.token}"
    }
  end
end
