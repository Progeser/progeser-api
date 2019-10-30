require 'test_helper'

class Users::RequesterTest < ActiveSupport::TestCase
  # Setups
  def setup
    @user = users(:user_1)
  end

  # Validations
  test 'valid user' do
    assert @user.valid?, @user.errors.messages
  end

  test 'invalid without email' do
    @user.email = nil
    assert_not @user.valid?
    assert_not_empty @user.errors[:email]
  end

  test 'invalid with existing email' do
    @user.email = users(:user_2).email
    assert_not @user.valid?
    assert_not_empty @user.errors[:email]
  end

  test 'invalid with incorrect email value' do
    @user.email = 'foo'
    assert_not @user.valid?
    assert_not_empty @user.errors[:email]
  end

  test 'invalid without password' do
    @user.password = nil
    assert_not @user.valid?
    assert_not_empty @user.errors[:password]
  end

  test 'invalid without first_name' do
    @user.first_name = nil
    assert_not @user.valid?
    assert_not_empty @user.errors[:first_name]
  end

  test 'invalid without last_name' do
    @user.last_name = nil
    assert_not @user.valid?
    assert_not_empty @user.errors[:last_name]
  end
end

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  role               :string
#  last_name          :string
#  first_name         :string
#  type               :string
#  laboratory         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email           (email)
#  index_users_on_remember_token  (remember_token)
#
