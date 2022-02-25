#
# Haz class model class.
#
class Colin::Models::HazClass < ActiveRecord::Base
    scope :toplevel, -> {where(superclass_id: nil)}
    
    validates_presence_of :description
    has_many :subclasses, class_name: "HazClass", foreign_key: "superclass_id"
    belongs_to :superclass, class_name: "HazClass"
end
  