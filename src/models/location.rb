#
# Location model class.
#
class Colin::Models::Location < ActiveRecord::Base
  validates_presence_of :name
end
