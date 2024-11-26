# frozen_string_literal: true

require 'test_helper'

class RequestDistributionTest < ActiveSupport::TestCase
  # Setups
  def setup
    @request_distribution = request_distributions(:request_distribution1)
  end

  # Validations
  test 'valid request_distribution' do
    assert @request_distribution.valid?, @request_distribution.errors.messages
  end

  test 'invalid without plant_stage' do
    @request_distribution.plant_stage = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:plant_stage]
  end

  test 'invalid with plant_stage from the non-requested plant' do
    @request_distribution.plant_stage = PlantStage.last
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:plant_stage]
  end
end

# == Schema Information
#
# Table name: request_distributions
#
#  id             :bigint           not null, primary key
#  request_id     :bigint
#  plant_stage_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_request_distributions_on_plant_stage_id  (plant_stage_id)
#  index_request_distributions_on_request_id      (request_id)
#
