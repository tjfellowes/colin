#
# Pictogram model class.
#
class Colin::Models::Pictogram < ActiveRecord::Base
    validates_presence_of :name
    validates_presence_of :picture
end
  