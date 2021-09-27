#
# Location type model class.
#
class Colin::Models::LocationType < ActiveRecord::Base
    validates_presence_of :name
end
  