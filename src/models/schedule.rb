#
# Schedule model class.
#
class Colin::Models::Schedule < ActiveRecord::Base
  # Must have a number
  validates :number, presence: true
end
