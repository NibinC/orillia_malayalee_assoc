class HomeController < ApplicationController
  def index
    @events = Event.published.order(:starts_at)
  end
end
