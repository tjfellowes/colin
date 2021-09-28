#
# Location model class.
#
require 'ancestry'

class Colin::Models::Location < ActiveRecord::Base
  has_ancestry
  validates_presence_of :name
  has_many :container_locations
  has_many :containers, through: :container_locations
  belongs_to :location_type
  has_many :standards, through: :location_standards
end
