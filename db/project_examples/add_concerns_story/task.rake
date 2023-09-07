desc 'Make data consistent before adding foreign keys and constraints'

namespace :make_data_consistent do
  task update: :environment do
    # AccountActivity
    p 'Updating AccountActivities'
    AccountActivity.left_joins(:user).where(users: { id: nil }).delete_all
    AccountActivity.left_joins(:plan).where(plans: { id: nil }).update_all(plan_id: nil)

    # ClassSchedule
    p 'Updating ClassSchedules'
    ClassSchedule.left_joins(:location).where(locations: { id: nil }).delete_all

    # ClassTypeName
    p 'Updating ClassTypeNames'
    ClassTypeName.left_joins(:class_type).where(class_types: { id: nil }).delete_all

    # ClassType
    p 'Updating ClassTypes'
    ClassType.left_joins(:integration).where(integrations: { id: nil }).delete_all

    # Reservation
    p 'Updating Reservations'
    Reservation.left_joins(:class_type).where(class_types: { id: nil }).update_all(class_type_id: nil)
    Reservation.left_joins(:scheduled_class).where(scheduled_classes: { id: nil }).update_all(scheduled_class_id: nil)
    Reservation.left_joins(:class_type_name).where(class_type_names: { id: nil }).update_all(class_type_name_id: nil)

    # ScheduledClasse
    p 'Updating ScheduledClasses'
    ScheduledClass.left_joins(:class_type).where(class_types: { id: nil }).delete_all
    ScheduledClass.left_joins(:staff).where(staffs: { id: nil }).delete_all

    # Staff
    p 'Updating Staffs'
    Staff.left_joins(:integration).where(integrations: { id: nil }).delete_all

    # AllocationPeriodSummary
    p 'Updating AllocationPeriodSummaries'
    AllocationPeriodSummary.left_joins(:user).where(users: { id: nil }).delete_all
    AllocationPeriodSummary.left_joins(:plan).where(plans: { id: nil }).delete_all

    p 'Done'
  end
end
