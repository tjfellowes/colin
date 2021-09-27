#
# Signal word model class.
#
class Colin::Models::SignalWord < ActiveRecord::Base
    validates_presence_of :name
end
  