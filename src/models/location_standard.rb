#
# Location standard model class.
#
class Colin::Models::LocationStandard < ActiveRecord::Base
  belongs_to :location
  belongs_to :standard
end
