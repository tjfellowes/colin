#
# Container model class.
#
class Colin::Models::Container < ActiveRecord::Base
  # Validate the presence of the non-NULLable fields.
  validates_presence_of :chemical_id, :date_purchased, :serial_number

  # Foreign key relationships
  belongs_to :supplier
end
