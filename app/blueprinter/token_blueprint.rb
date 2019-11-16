# frozen_string_literal: true

class TokenBlueprint < Base
  # Fields
  field :token, name: :access_token
  fields :token_type, :expires_in, :refresh_token, :created_at

  exclude :updated_at
end
