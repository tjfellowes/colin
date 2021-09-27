#
# Chemcial pictogram model class.
#
class Colin::Models::ChemicalPictogram < ActiveRecord::Base
  belongs_to :pictogram
  belongs_to :chemical
end
