#
# Container Content model class.
#
class Colin::Models::ContainerContent < ActiveRecord::Base
  belongs_to :chemical
  belongs_to :container
end
