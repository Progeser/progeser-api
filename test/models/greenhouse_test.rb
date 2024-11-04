# frozen_string_literal: true

require 'test_helper'

class GreenhouseTest < ActiveSupport::TestCase
  # Setups
  def setup
    @greenhouse = greenhouses(:greenhouse1)
  end

  # Validations
  test 'valid greenhouse' do
    assert @greenhouse.valid?, @greenhouse.errors.messages
  end

  test 'invalid without name' do
    @greenhouse.name = nil
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:name]
  end

  test 'invalid without width' do
    @greenhouse.width = nil
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:width]
  end

  test 'invalid without height' do
    @greenhouse.height = nil
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:height]
  end

  test 'invalid without occupancy' do
    @greenhouse.occupancy = nil
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:occupancy]
  end

  test 'invalid with incorrect width value' do
    @greenhouse.width = 0
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:width]
  end

  test 'invalid with incorrect height value' do
    @greenhouse.height = 0
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:height]
  end

  test 'invalid with too low occupancy value' do
    @greenhouse.occupancy = -1
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:occupancy]
  end

  test 'invalid with too high occupancy value' do
    @greenhouse.occupancy = 101
    assert_not @greenhouse.valid?
    assert_not_empty @greenhouse.errors[:occupancy]
  end
end

# == Schema Information
#
# Table name: greenhouses
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  width       :integer          not null
#  height      :integer          not null
#  occupancy   :decimal(, )      default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  building_id :bigint
#
# Indexes
#
#  index_greenhouses_on_building_id  (building_id)
#
# Foreign Keys
#
#  fk_rails_...  (building_id => buildings.id)
#
