# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def create_from_invite?
    true
  end

  # In this method, `record` refers to an account_request
  #
  def create_from_account_request?
    return true if record.accepted?

    record.errors.add(:accepted, 'must be accepted')
    false
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.where(id: user.id)
    end
  end
end
