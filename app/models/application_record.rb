# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Public class methods
  def self.to_blueprint(opts = {})
    "#{name}Blueprint".constantize.render(all, opts)
  end

  # Public instance methods
  def to_blueprint(opts = {})
    "#{self.class.name}Blueprint".constantize.render(self, opts)
  end
end
