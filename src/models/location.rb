#
# Location model class.
#
require 'ancestry'

class Colin::Models::Location < ActiveRecord::Base
  scope :active, -> {where("date_deleted IS NULL OR date_deleted > ?",Time.now )}

  has_ancestry
  validates_presence_of :name
  has_many :container_locations
  has_many :containers, through: :container_locations, class_name: "Container"
  belongs_to :location_type
  has_many :location_standards
  has_many :standards, through: :location_standards, class_name: "Standard"

  def location_path 
    path = []
    self.path_ids.each do |location_id|
      path.append(Colin::Models::Location.where(id: location_id).take.name)
    end 
    return path.join('/')
  end
end
