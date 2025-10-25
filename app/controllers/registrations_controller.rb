class RegistrationsController < ApplicationController
  before_action :set_event

  def new
    @registration = @event.registrations.new
    # Build 1 adult row by default; users can add/remove via JS on the form
    1.times { @registration.attendees.build(category: "adult") }
  end

  def create
    @registration = @event.registrations.new(registration_params)
    @registration.status = "pending"

    # Compute total based on attendee categories
    adult_count = @registration.attendees.count { |a| a.category == "adult" }
    minor_count = @registration.attendees.count { |a| a.category == "minor" }

    total = (adult_count * @event.adult_price_cents) + (minor_count * @event.minor_price_cents)
    @registration.total_cents = total
    @registration.currency = @event.currency

    if @registration.save
      redirect_to event_registration_path(@event, @registration)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @registration = @event.registrations.find(params[:id])
  end

  def invoice
    @registration = @event.registrations.find(params[:id])
    
    # Only allow invoice access for paid registrations
    unless @registration.status == 'paid'
      redirect_to event_registration_path(@event, @registration), 
                  alert: 'Invoice is only available after payment is completed.'
      return
    end
    
    respond_to do |format|
      format.html { render template: "registrations/invoice" }
      format.pdf do
        render pdf: "invoice_#{@registration.id}",
               template: "registrations/invoice",
               layout: "pdf",
               disposition: 'attachment',
               filename: "invoice_#{@registration.id}_#{@event.name.parameterize}.pdf",
               page_size: 'A4',
               margin: {
                 top: 20,
                 bottom: 20,
                 left: 20,
                 right: 20
               },
               encoding: 'UTF-8',
               print_media_type: true,
               disable_smart_shrinking: true,
               use_xvfb: false,
               no_background: false
      end
    end
  end
  
  def send_invoice_email
    @registration = @event.registrations.find(params[:id])
    
    if @registration.status == 'paid'
      InvoiceMailer.send_invoice(@registration).deliver_now
      redirect_to event_registration_path(@event, @registration), 
                  notice: 'Invoice has been sent to your email address!'
    else
      redirect_to event_registration_path(@event, @registration), 
                  alert: 'Invoice can only be sent after payment is completed.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def registration_params
    params.require(:registration).permit(
      :first_name, :last_name, :email,
      attendees_attributes: [:first_name, :last_name, :dob, :category, :_destroy]
    )
  end
end
