#
# Location model class.
#
class Colin::Models::Location < ActiveRecord::Base
  validates_presence_of :name
  has_many :sublocations, class_name: "Location", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Location"
end
