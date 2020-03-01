# frozen_string_literal: true

class GreenhousePolicy < ApplicationPolicy
  def index?
    grower?
  end

  def show?
    grower?
  end

  def create?
    grower?
  end

  def update?
    grower?
  end

  def destroy?
    return false unless grower?

    return true if record.benches.flat_map(&:request_distributions).empty?

    record.errors.add(:request_distributions, 'can\'t delete a greenhouse with ongoing requests')
    false
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
