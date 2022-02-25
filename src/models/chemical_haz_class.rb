#
# Chemcial haz class model class.
#
class Colin::Models::ChemicalHazClass < ActiveRecord::Base
  belongs_to :haz_class
  belongs_to :chemical
end
