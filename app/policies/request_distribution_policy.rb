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

    if record.distributions.count.zero?
      true
    else
      record.errors.add(:request, 'can\'t delete request_distribution if there are any left distributions')
      false
    end
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
