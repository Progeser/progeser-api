# frozen_string_literal: true

class PotPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    return true if record.request_distributions.empty?

    record.errors.add(:request_distributions, 'can\'t update a pot with ongoing requests')
    false
  end

  def destroy?
    return true if record.request_distributions.empty?

    record.errors.add(:request_distributions, 'can\'t delete a pot with ongoing requests')
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
