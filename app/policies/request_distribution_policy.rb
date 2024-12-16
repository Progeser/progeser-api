# frozen_string_literal: true

class RequestDistributionPolicy < ApplicationPolicy
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
    true
  end

  def destroy?
    return true unless record.request.accepted?

    return true if record.request.request_distributions.count > 1

    record.errors.add(:request, 'can\'t delete the last distribution of an accepted request')
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
