#
# Chemcial prec stat supp model class.
#
class Colin::Models::ChemicalPrecStatSupp < ActiveRecord::Base
    validates_presence_of :position, :information
    belongs_to :chemical_prec_stats
  end
  