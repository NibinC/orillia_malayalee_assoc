class Admin::DashboardController < Admin::BaseController
  def index
    @events = Event.includes(:registrations).order(:starts_at)
  end
end
