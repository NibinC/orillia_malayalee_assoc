class RegistrationsController < ApplicationController
  before_action :set_event

  def new
    @registration = @event.registrations.new
    # Build 1 empty row by default; users can add/remove via JS on the form
    1.times { @registration.attendees.build }
  end

  def create
    @registration = @event.registrations.new(registration_params)
    @registration.status = "pending"

    if @registration.save
      redirect_to event_registration_path(@event, @registration)
    else
      Rails.logger.error "Registration save failed: #{ @registration.errors.full_messages.join(', ') }"
      @registration.attendees.each_with_index do |a,i|
        Rails.logger.error "Attendee ##{i} errors: #{a.errors.full_messages.join(', ')}" if a.errors.any?
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @registration = @event.registrations.find(params[:id])
    @registration.attendees.build if @registration.attendees.empty?
  end

  def update
    @registration = @event.registrations.find(params[:id])
    if @registration.update(registration_params)
      redirect_to event_registration_path(@event, @registration), notice: 'Registration updated successfully.'
    else
      render :edit, status: :unprocessable_entity
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

  # Temporary action for testing - mark registration as paid
  def mark_paid
    @registration = @event.registrations.find(params[:id])
    @registration.mark_paid!(payment_intent_id: "test_payment_#{Time.current.to_i}")
    redirect_to event_registration_path(@event, @registration), 
                notice: 'Registration marked as paid for testing!'
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def registration_params
    params.require(:registration).permit(
      :first_name, :last_name, :email,
      attendees_attributes: [:id, :first_name, :last_name, :dob, :category, :_destroy]
    )
  end
end
