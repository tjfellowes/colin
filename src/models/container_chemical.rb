#
# Container Chemical model class.
#
class Colin::Models::ContainerChemical < ActiveRecord::Base
  belongs_to :chemical
  belongs_to :container
end
