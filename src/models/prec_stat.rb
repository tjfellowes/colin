#
# Prec stat model class.
#
class Colin::Models::PrecStat < ActiveRecord::Base
    validates_presence_of :code
    validates_presence_of :description
end
  