#
# Chemical model class.
#
class Colin::Models::Chemical < ActiveRecord::Base
  # Validate the presence of the non-NULLable fields.
  validates_presence_of :cas, :name
  validates_inclusion_of :haz_substance, in: [true, false]

  # Validate that sds_url is actually a standard URL.
  # validates :sds_url,
  #           format: { with: URI::DEFAULT_PARSER.make_regexp },
  #           if: proc { |a| a.url.present? }

  # Foreign key relationships
  belongs_to :dg_class_1, class_name: 'DgClass'
  belongs_to :dg_class_2, class_name: 'DgClass'
  belongs_to :dg_class_3, class_name: 'DgClass'
  belongs_to :schedule
  belongs_to :packing_group
  belongs_to :signal_word

  has_many :chemical_haz_class, class_name: "ChemicalHazClass"
  has_many :chemical_pictogram, class_name: "ChemicalPictogram"
  has_many :chemical_haz_stat, class_name: "ChemicalHazStat"
  has_many :chemical_prec_stat, class_name: "ChemicalPrecStat"

  has_many :haz_class, through: :chemical_haz_class, class_name: "HazClass"
  has_many :pictogram, through: :chemical_pictogram, class_name: "Pictogram"
  has_many :haz_stat, through: :chemical_haz_stat, class_name: "HazStat"
  has_many :prec_stat, through: :chemical_prec_stat, class_name: "PrecStat"

  has_many :container_chemical, class_name: "ContainerChemical"
  has_many :container, through: :container_chemical, class_name: "Container"
end
