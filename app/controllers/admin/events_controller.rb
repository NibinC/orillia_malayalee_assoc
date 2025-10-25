class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :participants]

  def index
    @events = Event.includes(:registrations).order(:starts_at)
  end

  def show
    @registrations = @event.registrations.includes(:attendees).order(created_at: :desc)
    @paid_registrations = @registrations.where(status: "paid")
    
    # Statistics for the view
    @event_revenue = @paid_registrations.sum(:total_cents) / 100.0
    @paid_registrations_count = @paid_registrations.count
    @total_participants = @paid_registrations.joins(:attendees).count
    @total_adults = @paid_registrations.joins(:attendees).where(attendees: { category: "adult" }).count
    @total_minors = @paid_registrations.joins(:attendees).where(attendees: { category: "minor" }).count
    
    # Participants by category
    @adult_participants = Attendee.joins(:registration)
                                 .where(registrations: { event: @event, status: "paid" }, category: "adult")
                                 .includes(:registration)
                                 .order(:first_name, :last_name)
    
    @minor_participants = Attendee.joins(:registration)
                                 .where(registrations: { event: @event, status: "paid" }, category: "minor")
                                 .includes(:registration)
                                 .order(:first_name, :last_name)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    
    if @event.save
      redirect_to admin_root_path, notice: 'Event was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: 'Event was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @event.registrations.any?
      redirect_to admin_root_path, alert: 'Cannot delete event with existing registrations.'
    else
      @event.destroy
      redirect_to admin_root_path, notice: 'Event was successfully deleted.'
    end
  end
  
  def participants
    @adult_participants = Attendee.joins(:registration)
                                 .where(registrations: { event: @event, status: "paid" }, category: "adult")
                                 .includes(:registration)
                                 .order(:first_name, :last_name)
    
    @minor_participants = Attendee.joins(:registration)
                                 .where(registrations: { event: @event, status: "paid" }, category: "minor")
                                 .includes(:registration)
                                 .order(:first_name, :last_name)
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :description, :starts_at, :adult_price_cents, :minor_price_cents, :currency, :published)
  end
end