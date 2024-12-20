# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def requests_to_handle_count?
    true
  end

  def show?
    true
  end

  def accept?
    true
  end

  def refuse?
    true
  end

  def cancel?
    true
  end

  def complete?
    true
  end

  def update?
    if record.request_distributions.exists?
      record.errors.add(:base, 'cannot update a request with associated request distributions')
      false
    else
      true
    end
  end

  def destroy?
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
