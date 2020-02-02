require 'test_helper'

class PotTest < ActiveSupport::TestCase
  # Setups
  def setup
    @pot = pots(:pot_1)
  end

  # Validations
  test 'valid pot' do
    assert @pot.valid?, @pot.errors.messages
  end

  test 'invalid without name' do
    @pot.name = nil
    assert_not @pot.valid?
    assert_not_empty @pot.errors[:name]
  end

  test 'invalid without shape' do
    @pot.shape = nil
    assert_not @pot.valid?
    assert_not_empty @pot.errors[:shape]
  end

  test 'invalid without area' do
    @pot.area = nil
    assert_not @pot.valid?
    assert_not_empty @pot.errors[:area]
  end

  test 'invalid with negative area' do
    @pot.area = -1
    assert_not @pot.valid?
    assert_not_empty @pot.errors[:area]
  end

  test 'invalid with null area' do
    @pot.area = 0
    assert_not @pot.valid?
    assert_not_empty @pot.errors[:area]
  end

  # Enumerize
  test 'invalid with incorrect shape value' do
    @pot.shape = 'foo'
    assert_not @pot.valid?
    assert_not_empty @pot.errors[:shape]
  end
end

# == Schema Information
#
# Table name: pots
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  shape      :string           not null
#  area       :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  dimensions :integer          is an Array
#
