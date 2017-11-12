#
# Chemical model class.
#
class Colin::Models::Chemical < ActiveRecord::Base
  # Validate the presence of the non-NULLable fields.
  validates_presence_of :cas, :prefix, :name, :haz_substance, :sds_url,
                        :un_number, :serial_number

  # Validate that sds_url is actually a standard URL.
  validates :sds_url,
            format: { with: URI::DEFAULT_PARSER.make_regexp },
            if: proc { |a| a.url.present? }

  # Foreign key relationships
  belongs_to :dg_class
  belongs_to :schedule
  belongs_to :packing_group
end
