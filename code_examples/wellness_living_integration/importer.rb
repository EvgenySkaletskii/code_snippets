class WellnessLiving::Importer < Importer
  include WellnessLiving::StateCodeParser

  def import!
    delete_past_scheduled_classes!

    api.login

    sync_locations(api.locations)
    sync_staff(api.staff)

    classes = api.classes(get_schedule)
    sync_classes(classes)
  end

  def sync_locations(locations = api.locations)
    locations.each do |location|
      create_or_update_location(location[:k_location], {
        external_name: location[:s_title],
        external_latitude: location[:f_latitude],
        external_longitude: location[:f_longitude],
        external_country_code: 'US',
        external_state_prov_code: parse_state_code(location[:text_region]),
        external_city: location[:text_city],
        external_address_line_1: location[:text_address_individual],
        external_postal_code: location[:text_postal],
        business: @business,
        enabled: true,
        can_book: true
      })
    end
  end

  def sync_staff(staff)
    staff.each do |employee|
      create_or_update_staff(employee[:k_staff], {
        name: employee[:text_name_full],
        first_name: employee[:s_name],
        last_name: employee[:s_surname]
      })
    end
  end

  def sync_classes(classes)
    classes.each do |c|
      class_info = c[:a_class]
      location_info = c[:a_location]
      staff_info = c[:a_staff].first

      class_type = create_or_update_class_type(class_info[:k_class], {
        external_name: class_info[:s_title],
        virtual: class_info[:is_virtual]
      })

      location = IntegrationLocation.find_by(external_location_id: location_info[:k_location]).location
      staff = Staff.find_by(external_id: staff_info[:k_staff])
      
      starts_at = DateTime.parse(class_info[:dt_date_global])
      ends_at = starts_at + class_info[:i_duration].minutes

      create_or_update_scheduled_class(c[:k_class_period], location, {
        external_name: class_info[:s_title],
        starts_at: starts_at,
        ends_at: ends_at,
        price: class_info[:m_price].to_f,
        bookable: class_info[:can_book],
        capacity: class_info[:i_capacity],
        open_spaces: class_info[:i_capacity] - class_info[:i_book],
        staff: staff,
        class_type: class_type
      })

      @business.seen_bookable
      class_type.seen_bookable
      location.seen_bookable
      staff.seen_bookable
    end
  end

  private

  def get_schedule
    location_ids = @integration.integration_locations.enabled.pluck(:external_location_id)

    start_date = Date.today.strftime('%Y-%m-%d')
    end_date = (Date.today + 2.weeks).strftime('%Y-%m-%d')

    classes = api.class_list(start_date: start_date, end_date: end_date)

    classes.select { |c| location_ids.include?(c[:k_location]) && !c[:k_class_period].nil? }.map do |c|
      {
        dt_date: c[:dt_date],
        k_class_period: c[:k_class_period]
      }
    end
  end

  def create_or_update_scheduled_class(external_id, location, attributes)
    sc = @integration.scheduled_classes.find_or_initialize_by(
      business: @integration.business,
      location: location,
      external_id: external_id,
      starts_at: attributes[:starts_at]
    )
    sc.assign_attributes(attributes)

    yield sc if block_given?

    sc.save!
    sc
  end
end
