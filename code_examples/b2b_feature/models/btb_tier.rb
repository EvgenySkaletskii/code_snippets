# frozen_string_literal: true

class BtbTier < ApplicationRecord
  BASE_GROUP = %w[Base Pro Core].freeze
  PREMIER_GROUP = %w[Peak Premier].freeze

  has_many :users, dependent: :nullify
  has_many :plans, dependent: :nullify
  has_many :disbursement_rules, dependent: :nullify
  has_many :scheduled_classes

  validates :name, :min_rate, :max_rate, presence: true
  validates :override, inclusion: [true, false]
  validates :virtual, inclusion: [true, false]
  validates :name, length: { maximum: 100 }
  validates :min_rate, :max_rate, numericality: { greater_than_or_equal_to: 0 },
                                  format: { with: /\A\d+(\.\d{1,2})?\z/ }
  validates :monthly_cap, presence: true,
                          numericality: { greater_than_or_equal_to: 0 },
                          format: { with: /\A\d+(\.\d{1,2})?\z/ },
                          if: -> { override? }
  validate :validate_tier_borders, unless: -> { virtual? }

  scope :with_range_for, ->(value) { where('min_rate <= :value AND max_rate >= :value', value: value) }
  scope :with_tiers_below, ->(tier) { where('max_rate <= ?', tier.max_rate) }
  scope :base_group, -> { where(name: BASE_GROUP) }
  scope :premier_group, -> { where(name: PREMIER_GROUP) }
  scope :not_virtual, -> { where(virtual: false) }

  def self.find_tier(rule)
    tier = not_virtual.with_range_for(rule.amount).first

    return nil unless tier

    if rule.cap_amount
      override = tier.override? && (rule.cap_amount < tier.monthly_cap)
      tier = where('max_rate > ?', tier.min_rate - 0.1).first if override
    end

    tier
  end

  def default_plan
    Plan.default_price_options.employer_plans.find_by(btb_tier_id: id)
  end

  def default_price
    default_plan&.monthly_price
  end

  def base_group?
    BtbTier.base_group.include?(self)
  end

  def premier_group?
    BtbTier.premier_group.include?(self)
  end

  def above?(tier)
    tier.max_rate < self.max_rate
  end

  def peak?
    name == 'Peak'
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
