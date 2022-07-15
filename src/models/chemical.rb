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

  has_and_belongs_to_many :haz_class
  has_and_belongs_to_many :pictogram
  has_and_belongs_to_many :haz_stat
  has_and_belongs_to_many :prec_stat

  has_many :container_content
  has_many :container, through: :container_content

  acts_as_paranoid

end
