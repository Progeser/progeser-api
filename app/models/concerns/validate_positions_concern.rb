# frozen_string_literal: true

require 'active_support/concern'

module ValidatePositionsConcern
  extend ActiveSupport::Concern

  included do
    validates :standardized_positions,
              presence: true,
              length: { is: 2, message: I18n.t('activerecord.errors.concern.attributes.positions.incorrect_size') }
    validate :positions_must_be_positive

    private

    def standardized_positions
      is_a?(RequestDistribution) ? positions_on_bench : positions
    end

    def positions_must_be_positive
      return unless standardized_positions

      return unless standardized_positions.any?(&:negative?)

      errors.add(:standardized_positions, I18n.t('activerecord.errors.concern.attributes.positions.not_positive'))
    end
  end
end
