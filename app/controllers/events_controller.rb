class EventsController < ApplicationController
  def index
    @events = Event.published.order(:starts_at)
  end

  def show
    @event = Event.find(params[:id])
  end
end
