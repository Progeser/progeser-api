# frozen_string_literal: true

class ApplicationInteractor
  include Dry::Transaction

  class << self
    attr_accessor :input_schema
  end

  # internal: Define a contract for the input of this interactor using `dry-validation`
  #
  def self.input(&block)
    @input_schema = Class.new(Dry::Validation::Contract, &block).new
  end

  # Call the interactor with its arguments.
  #
  def self.call(*args)
    new.call(*args)
  end

  private

  # internal: Validates input with the class attribute `schema` if it is defined.
  #
  # Add this step to your interactor if you want to validate its input.
  #
  def validate_input!(input)
    return Success(input) unless self.class.input_schema

    result = self.class.input_schema.call(input)

    if result.success?
      Success(result.values)
    else
      Failure(result)
    end
  end

  # internal: Wraps the steps inside an AR transaction.
  #
  # Add this step to your interactor if you want to wrap its operations inside a
  # database transaction
  #
  def database_transaction!(input)
    result = nil

    ActiveRecord::Base.transaction do
      result = yield(Success(input))
      raise ActiveRecord::Rollback if result.failure?
    end

    result
  end
end
