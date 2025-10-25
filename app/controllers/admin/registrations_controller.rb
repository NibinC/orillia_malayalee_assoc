class Admin::RegistrationsController < Admin::BaseController
  def index
    @registrations = Registration.includes(:event, :attendees).order(created_at: :desc)
  end

  def show
    @registration = Registration.find(params[:id])
  end
end
