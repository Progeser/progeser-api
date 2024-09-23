# frozen_string_literal: true

require 'test_helper'

class PlantStageTest < ActiveSupport::TestCase
  # Setups
  def setup
    @plant_stage = plant_stages(:plant_stage1)
  end

  # Validations
  test 'valid plant_stage' do
    assert @plant_stage.valid?, @plant_stage.errors.messages
  end

  test 'invalid without name' do
    @plant_stage.name = nil
    assert_not @plant_stage.valid?
    assert_not_empty @plant_stage.errors[:name]
  end

  test 'invalid without position' do
    @plant_stage.position = nil
    assert_not @plant_stage.valid?
    assert_not_empty @plant_stage.errors[:position]
  end

  test 'invalid without duration' do
    @plant_stage.duration = nil
    assert_not @plant_stage.valid?
    assert_not_empty @plant_stage.errors[:duration]
  end

  test 'invalid with incorrect position value (get converted into a valid one)' do
    @plant_stage.position = 0
    @plant_stage.save

    assert @plant_stage.valid?
    assert @plant_stage.id = 1
  end

  test 'invalid with incorrect duration value' do
    @plant_stage.duration = 0
    assert_not @plant_stage.valid?
    assert_not_empty @plant_stage.errors[:duration]
  end

  # Acts As List
  test 'Acts As List: auto-update plant_stages positions and keep them unique' do
    @plant_stage.position = 6
    @plant_stage.save

    plant = @plant_stage.plant
    assert_empty plant.plant_stages.where(position: 6).where.not(id: @plant_stage.id)
  end
end

# == Schema Information
#
# Table name: plant_stages
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  duration   :integer
#  position   :integer          not null
#  plant_id   :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_plant_stages_on_plant_id  (plant_id)
#
