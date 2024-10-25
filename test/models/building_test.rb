# frozen_string_literal: true

require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
  # Setups
  def setup
    @building = buildings(:building1)
  end

  # Validations
  test 'valid building' do
    assert @building.valid?, @building.errors.messages
  end

  test 'invalid without name' do
    @building.name = nil
    assert_not @building.valid?
    assert_not_empty @building.errors[:name]
  end

  # Test the relationship with greenhouses
  test 'building has many greenhouses' do
    assert_respond_to @building, :greenhouses
    assert_instance_of Greenhouse, @building.greenhouses.build
  end
end

# == Schema Information
#
# Table name: buildings
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_buildings_on_name  (name)
