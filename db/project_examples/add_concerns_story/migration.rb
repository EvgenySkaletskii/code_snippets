class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    # AccountActivity
    add_foreign_key :account_activities, :users, on_delete: :nullify
    add_foreign_key :account_activities, :users, column: :initiated_by_id
    add_foreign_key :account_activities, :markets
    add_foreign_key :account_activities, :plans
    change_column_null :account_activities, :user_id, false
    add_index :account_activities, :initiated_by_id
    add_index :account_activities, :market_id
    add_index :account_activities, :plan_id

    # Business
    add_foreign_key :businesses, :business_groups

    # ClassCredit
    add_foreign_key :class_credits, :users
    add_foreign_key :class_credits, :transactions, column: :transaction_id
    change_column_null :class_credits, :user_id, false

    # ClassSchedule
    add_foreign_key :class_schedules, :businesses, on_delete: :cascade
    add_foreign_key :class_schedules, :class_types, on_delete: :cascade
    add_foreign_key :class_schedules, :locations, on_delete: :cascade

    # ClassTypeName
    add_foreign_key :class_type_names, :class_types, on_delete: :cascade
    change_column_null :class_type_names, :class_type_id, false

    # ClassType
    add_foreign_key :class_types, :integrations, on_delete: :cascade
    add_foreign_key :class_types, :businesses, on_delete: :cascade
    add_foreign_key :class_types, :class_type_names, column: :current_class_type_name_id, on_delete: :nullify
    change_column_null :class_types, :integration_id, false
    change_column_null :class_types, :business_id, false
    add_index :class_types, :integration_id
    add_index :class_types, :current_class_type_name_id

    # IntegrationLocation
    add_foreign_key :integration_locations, :integrations, on_delete: :cascade
    add_foreign_key :integration_locations, :locations, on_delete: :cascade
    change_column_null :integration_locations, :integration_id, false

    # Integration
    add_foreign_key :integrations, :businesses, on_delete: :cascade
    change_column_null :integrations, :business_id, false

    # Invitation
    add_foreign_key :invitations, :markets
    add_foreign_key :invitations, :users
    add_foreign_key :invitations, :users, column: :invited_by_id
    add_foreign_key :invitations, :email_csvs
    change_column_null :invitations, :market_id, false
    add_index :invitations, :market_id
    add_index :invitations, :user_id
    add_index :invitations, :invited_by_id
    add_index :invitations, :email_csv_id

    # Location
    add_foreign_key :locations, :businesses, on_delete: :cascade
    add_foreign_key :locations, :markets
    add_foreign_key :locations, :disbursement_groups
    change_column_null :locations, :business_id, false
    add_index :locations, :market_id

    # PendingPlanChange
    add_foreign_key :pending_plan_changes, :plans
    add_foreign_key :pending_plan_changes, :users, column: :initiated_by_id
    change_column_null :pending_plan_changes, :plan_id, false
    change_column_null :pending_plan_changes, :initiated_by_id, false
    add_index :pending_plan_changes, :plan_id
    add_index :pending_plan_changes, :initiated_by_id

    # Plan
    add_foreign_key :plans, :markets
    add_foreign_key :plans, :partners
    change_column_null :plans, :market_id, false
    add_index :plans, :market_id
    add_index :plans, :partner_id

    # Reservation
    add_foreign_key :reservations, :markets
    add_foreign_key :reservations, :users
    add_foreign_key :reservations, :account_activities, column: :late_cancellation_fee_activity_id
    add_foreign_key :reservations, :businesses, on_delete: :cascade
    add_foreign_key :reservations, :locations
    add_foreign_key :reservations, :class_types
    add_foreign_key :reservations, :class_type_names
    add_foreign_key :reservations, :service_categories
    add_foreign_key :reservations, :staffs
    add_foreign_key :reservations, :rooms
    add_foreign_key :reservations, :spot_types
    add_foreign_key :reservations, :spots
    add_foreign_key :reservations, :scheduled_classes
    add_foreign_key :reservations, :class_credits
    change_column_null :reservations, :user_id, false
    change_column_null :reservations, :business_id, false
    change_column_null :reservations, :location_id, false
    change_column_null :reservations, :staff_id, false
    add_index :reservations, :market_id
    add_index :reservations, :late_cancellation_fee_activity_id
    add_index :reservations, :class_type_name_id
    add_index :reservations, :service_category_id
    add_index :reservations, :staff_id
    add_index :reservations, :room_id
    add_index :reservations, :spot_type_id
    add_index :reservations, :spot_id
    add_index :reservations, :scheduled_class_id
    add_index :reservations, :class_credit_id

    # ScheduledClass
    add_foreign_key :scheduled_classes, :integrations
    add_foreign_key :scheduled_classes, :class_schedules
    add_foreign_key :scheduled_classes, :businesses, on_delete: :cascade
    add_foreign_key :scheduled_classes, :locations, on_delete: :cascade
    add_foreign_key :scheduled_classes, :class_types, on_delete: :cascade
    add_foreign_key :scheduled_classes, :staffs
    add_foreign_key :scheduled_classes, :service_categories
    add_foreign_key :scheduled_classes, :rooms
    add_foreign_key :scheduled_classes, :layouts
    change_column_null :scheduled_classes, :integration_id, false
    add_index :scheduled_classes, :integration_id
    add_index :scheduled_classes, :class_schedule_id
    add_index :scheduled_classes, :staff_id
    add_index :scheduled_classes, :service_category_id
    add_index :scheduled_classes, :room_id
    add_index :scheduled_classes, :layout_id

    # Staff
    add_foreign_key :staffs, :businesses, on_delete: :cascade
    add_foreign_key :staffs, :integrations, on_delete: :cascade
    add_index :staffs, :integration_id

    # User
    add_foreign_key :users, :markets
    add_foreign_key :users, :invitations, column: :last_viewed_invitation_id
    add_foreign_key :users, :users, column: :last_referring_user_id
    add_index :users, :market_id
    add_index :users, :last_viewed_invitation_id
    add_index :users, :last_referring_user_id

    # AllocationPeriodSummary
    add_foreign_key :allocation_period_summaries, :users
    add_foreign_key :allocation_period_summaries, :plans
    change_column_null :allocation_period_summaries, :user_id, false
    change_column_null :allocation_period_summaries, :plan_id, false
    add_index :allocation_period_summaries, :user_id
    add_index :allocation_period_summaries, :plan_id

    # AppStoreSubscription
    add_foreign_key :app_store_subscriptions, :users
    change_column_null :app_store_subscriptions, :user_id, false

    # CreditDelta
    add_foreign_key :credit_deltas, :users
    change_column_null :credit_deltas, :user_id, false
    add_index :credit_deltas, :user_id

    # ExternalAccount
    add_foreign_key :external_accounts, :users
    add_foreign_key :external_accounts, :integrations, on_delete: :cascade
    change_column_null :external_accounts, :user_id, false
    change_column_null :external_accounts, :integration_id, false
    add_index :external_accounts, :user_id
    add_index :external_accounts, :integration_id

    # GiftCard
    add_foreign_key :gift_cards, :credit_deltas
    add_index :gift_cards, :credit_delta_id

    # Layout
    add_foreign_key :layouts, :integrations
    add_foreign_key :layouts, :businesses
    add_foreign_key :layouts, :locations
    add_foreign_key :layouts, :rooms
    change_column_null :layouts, :integration_id, false
    change_column_null :layouts, :business_id, false
    change_column_null :layouts, :location_id, false
    change_column_null :layouts, :room_id, false

    # Nonce
    add_foreign_key :nonces, :users
    change_column_null :nonces, :user_id, false
    add_index :nonces, :user_id

    # Room
    add_foreign_key :rooms, :businesses, on_delete: :cascade
    add_foreign_key :rooms, :integrations, on_delete: :cascade
    add_index :rooms, :business_id
    add_index :rooms, :integration_id

    # ServiceCategory
    add_foreign_key :service_categories, :businesses
    add_foreign_key :service_categories, :integrations
    add_index :service_categories, :integration_id

    # SpotType
    add_foreign_key :spot_types, :integrations
    add_foreign_key :spot_types, :businesses, on_delete: :cascade
    change_column_null :spot_types, :integration_id, false
    change_column_null :spot_types, :business_id, false

    # Spot
    add_foreign_key :spots, :integrations
    add_foreign_key :spots, :businesses
    add_foreign_key :spots, :locations
    add_foreign_key :spots, :layouts
    add_foreign_key :spots, :spot_types
    add_foreign_key :spots, :rooms
    change_column_null :spots, :integration_id, false
    change_column_null :spots, :business_id, false
    change_column_null :spots, :location_id, false
    change_column_null :spots, :layout_id, false
    change_column_null :spots, :spot_type_id, false
    change_column_null :spots, :room_id, false

    # StudioDonation
    add_foreign_key :studio_donations, :locations
    change_column_null :studio_donations, :location_id, false

    # Transaction
    add_foreign_key :transactions, :users
    add_foreign_key :transactions, :partners
    add_index :transactions, :user_id
    add_index :transactions, :partner_id

    #DisbursementRule
    add_foreign_key :disbursement_rules, :businesses, on_delete: :cascade
    add_index :disbursement_rules, :business_id
  end
end
