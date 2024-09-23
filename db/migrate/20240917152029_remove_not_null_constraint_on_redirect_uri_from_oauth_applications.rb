# frozen_string_literal: true

class RemoveNotNullConstraintOnRedirectUriFromOauthApplications < ActiveRecord::Migration[7.2]
  def up
    change_column_null :oauth_applications, :redirect_uri, true
  end

  def down
    change_column_null :oauth_applications, :redirect_uri, false
  end
end
