#
# Chemical model class.
#
class Colin::Models::Chemical < ActiveRecord::Base
  # Validate the presence of the non-NULLable fields.
  validates_presence_of :cas, :name, :created_at, :updated_at, :name_fulltext
  validates_inclusion_of :haz_substance, in: [true, false]

  # Validate that sds_url is actually a standard URL.
  # validates :sds_url,
  #           format: { with: URI::DEFAULT_PARSER.make_regexp },
  #           if: proc { |a| a.url.present? }

  # Foreign key relationships
  belongs_to :dg_class, class_name: 'DgClass'
  belongs_to :dg_class_2, class_name: 'DgClass'
  belongs_to :dg_class_3, class_name: 'DgClass'
  belongs_to :schedule
  belongs_to :packing_group
  belongs_to :signal_word

  has_many :haz_classes, through: :chemical_haz_classes, class_name: "HazClass"
  has_many :pictograms, through: :chemical_pictograms, class_name: "Pictogram"
  has_many :haz_stats, through: :chemical_haz_stats, class_name: "HazStat"
  has_many :prec_stats, through: :chemical_prec_stats, class_name: "PrecStat"

  has_many :containers, class_name: "Container"
end
