#
# Container Location model class.
#
class Colin::Models::ContainerLocation < ActiveRecord::Base

  #Colin::Models::ContainerLocation.where(container_id: id).includes(location: :parent).order(:created_at).last

  validates_inclusion_of :temp, in: [true, false]

  belongs_to :container
  belongs_to :location, optional: true

  acts_as_paranoid
end
