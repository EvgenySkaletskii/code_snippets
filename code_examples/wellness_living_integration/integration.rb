class WellnessLiving::Integration < Integration
  include WellnessLivingHelper

  def _reserve!(reservation)
    return :sold_out unless can_book?(reservation)

    true
  end

  def _cancel!(reservation)
    true
  end

  def api
    @api ||= ::WellnessLiving::Api.new(configuration)
  end

  def user_manager
    @user_manager ||= ::WellnessLiving::UserManager.new(self)
  end

  def _synchronize!
    ::WellnessLiving::Importer.new(self).import!
  end

  def can_book?(reservation)
    scheduled_class = api.scheduled_class_info(reservation.external_scheduled_class_id)
    scheduled_class[:i_capacity] > scheduled_class[:i_book]
  end
end
