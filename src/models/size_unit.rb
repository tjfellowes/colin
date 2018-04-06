#
# Size Unit model class.
#
class Colin::Models::SizeUnit < ActiveRecord::Base
  validates_presence_of :name, :symbol, :multiplier
end
