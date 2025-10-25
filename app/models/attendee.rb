class Attendee < ApplicationRecord
  belongs_to :registration
  validates :first_name, :last_name, :dob, presence: true
  validates :category, inclusion: { in: %w[adult minor] }
  
  before_validation :calculate_category
  
  def age
    return nil unless dob.present?
    ((Date.current - dob) / 365.25).floor
  end
  
  def minor?
    age.present? && age < 12
  end
  
  def adult?
    age.present? && age >= 12
  end
  
  private
  
  def calculate_category
    return unless dob.present?
    self.category = minor? ? 'minor' : 'adult'
  end
end
