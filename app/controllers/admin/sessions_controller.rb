# frozen_string_literal: true

class Admin::SessionsController < Admin::BaseController
  def extend
    # Update the last request at timestamp for Devise timeout
    if current_admin_user
      current_admin_user.update_column(:last_request_at, Time.current)
      render json: { status: 'success', message: 'Session extended' }
    else
      render json: { status: 'error', message: 'Not authenticated' }, status: :unauthorized
    end
  end
end
