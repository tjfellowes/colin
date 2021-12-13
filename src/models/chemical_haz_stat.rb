#
# Chemcial haz stat model class.
#
class Colin::Models::ChemicalHazStat < ActiveRecord::Base
  belongs_to :haz_stat
  belongs_to :chemical
end
