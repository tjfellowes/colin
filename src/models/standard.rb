#
# Standard model class.
#
class Colin::Models::Standard < ActiveRecord::Base
    validates_presence_of :name
    validates_presence_of :description
end
  