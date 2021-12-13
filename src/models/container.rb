#
# Container model class.
#
class Colin::Models::Container < ActiveRecord::Base
  default_scope {where("date_disposed IS NULL OR date_disposed > ?",Time.now )}

  # Validate the presence of the non-NULLable fields.

  validates_presence_of :chemical_id, :date_purchased

  has_many :container_location, class_name: "ContainerLocation"
  has_many :location, through: :container_location, class_name: "Location"

  # Foreign key relationships
  belongs_to :supplier
  belongs_to :chemical
  belongs_to :user
  belongs_to :owner, class_name: "User"

  def current_location
    Colin::Models::ContainerLocation.where(container_id: id).order(:created_at).last
  end

  def storage_location
    Colin::Models::ContainerLocation.where(container_id: id, temp: false).order(:created_at).last
  end

end

