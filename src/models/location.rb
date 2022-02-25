#
# Location model class.
#
require 'ancestry'

class Colin::Models::Location < ActiveRecord::Base
  scope :active, -> {where("date_deleted IS NULL OR date_deleted > ?",Time.now )}
  scope :can_store_chemicals, -> {where(location_type: Colin::Models::LocationType.where.not(name: ['Building', 'Room']))}

  has_ancestry
  validates_presence_of :name
  has_many :container_location
  has_many :container, through: :container_locations, class_name: "Container"
  belongs_to :location_type
  has_many :location_standard
  has_many :standard, through: :location_standards, class_name: "Standard"

  def location_path 
    path = []
    if Colin::Models::LocationType.where(name: ['Building', 'Room']).include?(self.location_type)
      self.path_ids.each do |location_id|
        if location = Colin::Models::Location.where(id: location_id).take
          path.append(location.name)
        end
      end 
      return path.join('/')
    else
      self.path_ids.each do |location_id|
        if location = Colin::Models::Location.where(id: location_id).where(location_type: Colin::Models::LocationType.where.not(name: ['Building', 'Room'])).take
          path.append(location.name)
        end
      end 
      return path.join('/')
    end
  end
end
