# frozen_string_literal: true

desc 'Create default B2B tiers'

namespace :btb_tiers do
  task create: :environment do
    BtbTier.find_or_create_by(name: 'Base', min_rate: 0, max_rate: 4.99, override: false)
    BtbTier.find_or_create_by(name: 'Core', min_rate: 5, max_rate: 9.99, override: true, monthly_cap: 25)
    BtbTier.find_or_create_by(name: 'Pro', min_rate: 10, max_rate: 16, override: true, monthly_cap: 65)
    BtbTier.find_or_create_by(name: 'Premier', min_rate: 16.01, max_rate: 20, override: true, monthly_cap: 100)
    BtbTier.find_or_create_by(name: 'Peak', min_rate: 20.01, max_rate: 99_999.99, override: false)

    p "[#{DateTime.now}] Default B2B tiers have been created successfully"
    DisbursementRule.skip_callback(:commit, :after, :touch_scheduled_classes)

    DisbursementRule.find_each do |rule|
      rule.save
    end

    DisbursementRule.set_callback(:commit, :after, :touch_scheduled_classes)
    p "[#{DateTime.now}] #{DisbursementRule.count} disbursement rules was updated with tiers"

    p "[#{DateTime.now}] Running updating scheduled classes with tiers (DB)"

    ScheduledClass.skip_callback(:commit, :after, :async_solr_update)

    number_of_baches = ScheduledClass.count / 500

    ScheduledClass.in_batches(of: 500).each_with_index do |batch, index|
      p "[#{DateTime.now}] #{index}/#{number_of_baches} batch of 500 scheduled_classes started processing"
      batch.each(&:save)
      p "[#{DateTime.now}] #{index}/#{number_of_baches} batch of 500 scheduled_classes finished processing"
    end

    DisbursementRule.set_callback(:commit, :after, :async_solr_update)

    p "[#{DateTime.now}] Updated scheduled classes with tiers"
  end
end
