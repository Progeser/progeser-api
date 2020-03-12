# frozen_string_literal: true

class PotPolicy < ApplicationPolicy
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
    return false unless grower?

    return true if record.request_distributions.empty?

    record.errors.add(:request_distributions, 'can\'t update a pot with ongoing requests')
    false
  end

  def destroy?
    return false unless grower?

    return true if record.request_distributions.empty?

    record.errors.add(:request_distributions, 'can\'t delete a pot with ongoing requests')
    false
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
