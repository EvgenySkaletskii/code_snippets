class AddScheduledClassesCountToBtbTiers < ActiveRecord::Migration[5.2]
  def up
    add_column :btb_tiers, :scheduled_classes_count, :integer, default: 0

    # Set initial counter values for existing records
    BtbTier.find_each do |btb_tier|
      BtbTier.reset_counters(btb_tier.id, :scheduled_classes)
    end
  end

  def down
    remove_column :btb_tiers, :scheduled_classes_count
  end
end
