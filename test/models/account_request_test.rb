require 'test_helper'

class AccountRequestTest < ActiveSupport::TestCase
  # Setups
  def setup
    @account_request = account_requests(:account_request_1)
  end

  # Validations
  test 'valid account_request' do
    assert @account_request.valid?, @account_request.errors.messages
  end

  test 'invalid without email' do
    @account_request.email = nil
    assert_not @account_request.valid?
    assert_not_empty @account_request.errors[:email]
  end

  test 'invalid with existing email' do
    @account_request.email = account_requests(:account_request_2).email
    assert_not @account_request.valid?
    assert_not_empty @account_request.errors[:email]
  end

  test 'invalid with incorrect email value' do
    @account_request.email = 'foo'
    assert_not @account_request.valid?
    assert_not_empty @account_request.errors[:email]
  end

  test 'invalid without first_name' do
    @account_request.first_name = nil
    assert_not @account_request.valid?
    assert_not_empty @account_request.errors[:first_name]
  end

  test 'invalid without last_name' do
    @account_request.last_name = nil
    assert_not @account_request.valid?
    assert_not_empty @account_request.errors[:last_name]
  end
end

# == Schema Information
#
# Table name: account_requests
#
#  id             :bigint           not null, primary key
#  email          :string           not null
#  creation_token :string           not null
#  first_name     :string
#  last_name      :string
#  comment        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_account_requests_on_creation_token  (creation_token) UNIQUE
#  index_account_requests_on_email           (email) UNIQUE
#
