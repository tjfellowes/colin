#
# Haz stat model class.
#
class Colin::Models::HazStat < ActiveRecord::Base
    validates_presence_of :code
    validates_presence_of :description
end
  