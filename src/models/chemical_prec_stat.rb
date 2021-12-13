#
# Chemcial prec stat model class.
#
class Colin::Models::ChemicalPrecStat < ActiveRecord::Base
  belongs_to :prec_stat
  belongs_to :chemical
end
