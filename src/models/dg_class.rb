#
# Dangerous Goods model class.
#
class Colin::Models::DGClass < ActiveRecord::Base
  # Must have a description and number
  validates_presence_of :description, :number
end
