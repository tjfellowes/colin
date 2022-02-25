#
# Dangerous Goods model class.
#
class Colin::Models::DgClass < ActiveRecord::Base
  # Must have a description and number
  validates_presence_of :description, :number
  has_many :subclasses, class_name: "DgClass", foreign_key: "superclass_id"
  belongs_to :superclass, class_name: "DgClass"
end
