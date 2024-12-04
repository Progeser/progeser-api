# frozen_string_literal: true

require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  # Setups
  def setup
    @request = requests(:request1)
  end

  # Validations
  test 'valid request' do
    assert @request.valid?, @request.errors.messages
  end

  test 'valid without handler' do
    @request.handler = nil
    assert @request.valid?, @request.errors.messages
  end

  test 'valid without plant_stage and a non-accepted status' do
    @request.plant_stage = nil
    @request.status = :pending
    assert @request.valid?, @request.errors.messages
  end

  test 'valid without comment' do
    @request.comment = nil
    assert @request.valid?, @request.errors.messages
  end

  test 'valid without temperature' do
    @request.temperature = nil
    assert @request.valid?, @request.errors.messages
  end

  test 'valid without photoperiod' do
    @request.photoperiod = nil
    assert @request.valid?, @request.errors.messages
  end

  test 'valid without laboratory' do
    @request.laboratory = nil
    assert @request.valid?, @request.errors.messages
  end

  test 'invalid without requester_first_name' do
    @request.requester_first_name = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:requester_first_name]
  end

  test 'invalid without requester_last_name' do
    @request.requester_last_name = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:requester_last_name]
  end

  test 'invalid without requester_email' do
    @request.requester_email = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:requester_email]
  end

  test 'invalid without name' do
    @request.name = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:name]
  end

  test 'invalid without status' do
    @request.status = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:status]
  end

  test 'invalid without due_date' do
    @request.due_date = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:due_date]
  end

  test 'invalid without quantity' do
    @request.quantity = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:quantity]
  end

  test 'invalid without plant_name' do
    @request.plant_name = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:plant_name]
  end

  test 'invalid without plant_stage_name' do
    @request.plant_stage_name = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:plant_stage_name]
  end

  # Enumerize
  test 'invalid with incorrect status value' do
    @request.status = 'foo'
    assert_not @request.valid?
    assert_not_empty @request.errors[:status]
  end

  # State Machine
  test 'can\'t be accepted without at least one request distribution' do
    @request.request_distributions = []
    assert_not @request.valid?
    assert_not_empty @request.errors[:request_distributions]
  end

  test 'can\'t be accepted without a plant stage' do
    @request.plant_stage = nil
    assert_not @request.valid?
    assert_not_empty @request.errors[:plant_stage]
  end
end
