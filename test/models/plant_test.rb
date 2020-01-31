require 'test_helper'

class PlantTest < ActiveSupport::TestCase
  # Setups
  def setup
    @plant = plants(:plant_1)
  end

  # Validations
  test 'valid plant' do
    assert @plant.valid?, @plant.errors.messages
  end

  test 'invalid without name' do
    @plant.name = nil
    assert_not @plant.valid?
    assert_not_empty @plant.errors[:name]
  end

  # See comment on validation in app/models/plant.rb
  #
  # test 'invalid without plant_stages' do
  #   @plant.plant_stages.destroy_all
  #   assert_not @plant.valid?
  #   assert_not_empty @plant.errors[:plant_stages]
  # end
end

# == Schema Information
#
# Table name: plants
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
