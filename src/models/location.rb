#
# Location model class.
#
class Colin::Models::Location < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :name_fulltext
  has_many :sublocations, class_name: "Location", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Location"
  has_many :container_locations
  has_many :containers, through: :container_locations
  belongs_to :location_type
  has_many :standards, through: :location_standards

end
