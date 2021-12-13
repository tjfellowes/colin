#
# Supplier model class.
#
class Colin::Models::Supplier < ActiveRecord::Base
  validates_presence_of :name
end
