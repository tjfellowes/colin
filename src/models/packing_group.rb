#
# Packing Group model class.
#
class Colin::Models::PackingGroup < ActiveRecord::Base
  # Must have a name
  validates :name, presence: true
end
