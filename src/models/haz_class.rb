#
# Haz class model class.
#
class Colin::Models::HazClass < ActiveRecord::Base
    validates_presence_of :description
end
  