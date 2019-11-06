require 'test_helper'

class InviteTest < ActiveSupport::TestCase
  # Setups
  def setup
    @invite = invites(:invite_1)
  end

  # Validations
  test 'valid invite' do
    assert @invite.valid?, @invite.errors.messages
  end

  test 'invalid without email' do
    @invite.email = nil
    assert_not @invite.valid?
    assert_not_empty @invite.errors[:email]
  end

  test 'invalid with existing email' do
    @invite.email = invites(:invite_2).email
    assert_not @invite.valid?
    assert_not_empty @invite.errors[:email]
  end

  test 'invalid with incorrect email value' do
    @invite.email = 'foo'
    assert_not @invite.valid?
    assert_not_empty @invite.errors[:email]
  end

  test 'invalid without first_name' do
    @invite.first_name = nil
    assert_not @invite.valid?
    assert_not_empty @invite.errors[:first_name]
  end

  test 'invalid without last_name' do
    @invite.last_name = nil
    assert_not @invite.valid?
    assert_not_empty @invite.errors[:last_name]
  end

  test 'invalid without laboratory for a requester' do
    @invite.laboratory = nil
    assert_not @invite.valid?
    assert_not_empty @invite.errors[:laboratory]
  end

  test 'valid without laboratory for a grower' do
    invites(:invite_2).laboratory = nil
    assert invites(:invite_2).valid?
  end

  # Delegate
  test 'delegated methods' do
    assert @invite.requester?
    assert_not @invite.grower?
  end
end

# == Schema Information
#
# Table name: invites
#
#  id               :bigint           not null, primary key
#  email            :string           not null
#  invitation_token :string           not null
#  role             :string
#  first_name       :string
#  last_name        :string
#  laboratory       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_invites_on_email             (email) UNIQUE
#  index_invites_on_invitation_token  (invitation_token) UNIQUE
#
