# frozen_string_literal: true

class RequestDistributionPolicy < ApplicationPolicy
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

    return true unless record.request.accepted?

    return true if record.request.request_distributions.count > 1

    record.errors.add(:request, 'can\'t delete the last distribution of an accepted request')
    false
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
