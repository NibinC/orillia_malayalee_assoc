class InvoiceMailer < ApplicationMailer
  def send_invoice(registration)
    @registration = registration
    @event = registration.event
    
    # Generate PDF using wicked_pdf
    pdf_content = WickedPdf.new.pdf_from_string(
      render_to_string(
        template: 'registrations/invoice',
        layout: 'pdf'
      ),
      page_size: 'A4',
      margin: {
        top: 20,
        bottom: 20,
        left: 15,
        right: 15
      }
    )
    
    # Attach the PDF
    filename = "invoice_#{@registration.id}_#{@event.name.parameterize}.pdf"
    attachments[filename] = {
      mime_type: 'application/pdf',
      content: pdf_content
    }
    
    mail(
      to: @registration.email,
      subject: "🎉 Registration Confirmed: #{@event.name} - Invoice Attached",
      from: 'Orillia Malayalee Association <no-reply@orilliamalayalee.org>',
      reply_to: 'info@orilliamalayalee.org'
    )
  end
end
