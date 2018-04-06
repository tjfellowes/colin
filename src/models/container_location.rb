#
# Container Location model class.
#
class Colin::Models::ContainerLocation < ActiveRecord::Base
  validates_presence_of :date

  belongs_to :container
  belongs_to :storage_class
  belongs_to :location
end
