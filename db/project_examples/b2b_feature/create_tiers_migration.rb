class CreateBtbTiers < ActiveRecord::Migration[5.2]
  def change
    create_table :btb_tiers do |t|
      t.string :name
      t.decimal :min_rate
      t.decimal :max_rate
      t.decimal :monthly_cap
      t.boolean :override, default: false, null: false
    end

    add_reference :users, :btb_tier, foreign_key: true, index: true
    add_reference :disbursement_rules, :btb_tier, foreign_key: true, index: true
    add_reference :plans, :btb_tier, foreign_key: true, index: true
    add_reference :scheduled_classes, :btb_tier, foreign_key: true, index: true
  end
end
