# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def requests_to_handle_count?
    grower?
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

  def accept?
    grower?
  end

  def refuse?
    grower?
  end

  def cancel?
    true
  end

  def complete?
    grower?
  end

  def destroy?
    return false unless grower?

    return true if record.pending?

    record.errors.add(:status, 'can\'t delete a non-pending request')
    false
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.where(author: user)
    end
  end
end
