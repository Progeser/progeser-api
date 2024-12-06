# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def requests_to_handle_count?
    grower?
  end

  def show?
    grower?
  end

  def create?
    true
  end

  def accept?
    grower?
  end

  def refuse?
    grower?
  end

  def cancel?
    grower?
  end

  def complete?
    grower?
  end

  def destroy?
    return false unless grower?

    if record.pending?
      true
    else
      record.errors.add(:status, 'can\'t delete a non-pending request')
      false
    end
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
