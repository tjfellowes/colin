#
# Supplier model class.
#
class Colin::Models::Supplier < ActiveRecord::Base
  scope :active, -> {where("date_deleted IS NULL OR date_deleted > ?",Time.now )}

  validates_presence_of :name

  acts_as_paranoid
end
