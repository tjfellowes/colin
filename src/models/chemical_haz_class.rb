#
# Chemcial haz class model class.
#
class Colin::Models::ChemicalHazClass < ActiveRecord::Base
  validates_presence_of :category
  belongs_to :haz_class
  belongs_to :chemical
end
