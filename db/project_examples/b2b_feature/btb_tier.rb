# frozen_string_literal: true

class BtbTier < ApplicationRecord
  validate :validate_tier_borders, unless: -> { virtual? }

  scope :with_range_for, ->(value) { where('min_rate <= :value AND max_rate >= :value', value: value) }
  scope :with_tiers_below, ->(tier) { where('max_rate <= ?', tier.max_rate) }
  scope :with_tiers_above, ->(tier) { where('max_rate > ?', tier.max_rate) }

  def self.find_tier(rule)
    tier = not_virtual.with_range_for(rule.amount).first

    return nil unless tier

    if rule.cap_amount
      override = tier.override? && (rule.cap_amount < tier.monthly_cap)
      tier = where('max_rate > ?', tier.min_rate - 0.1).first if override
    end

    tier
  end

  private

  def validate_tier_borders
    if BtbTier.with_range_for(min_rate).where.not(id: id).exists?
      errors.add :min_rate, 'Min rate crosses existed tier borders'
    end

    if BtbTier.with_range_for(max_rate).where.not(id: id).exists?
      errors.add :max_rate, 'Max rate crosses existed tier borders'
    end
  end
end
