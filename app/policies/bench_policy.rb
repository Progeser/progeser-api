# frozen_string_literal: true

class BenchPolicy < ApplicationPolicy
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

    return true if record.distributions.empty?

    record.errors.add(:distributions, 'can\'t delete a bench with ongoing requests')
    false
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
