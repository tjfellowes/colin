#
# Container model class.
#
class Colin::Models::Container < ActiveRecord::Base
  # Foreign key relationships
  belongs_to :supplier
  belongs_to :user
  belongs_to :owner, class_name: "User"

  belongs_to :dg_class_1, class_name: 'DgClass'
  belongs_to :dg_class_2, class_name: 'DgClass'
  belongs_to :dg_class_3, class_name: 'DgClass'
  belongs_to :schedule
  belongs_to :packing_group
  belongs_to :signal_word

  has_many :container_location
  has_many :location, through: :container_location

  has_many :container_content
  has_many :chemical, through: :container_content

  has_and_belongs_to_many :haz_class
  has_and_belongs_to_many :pictogram
  has_and_belongs_to_many :haz_stat
  has_and_belongs_to_many :prec_stat

  def current_location
    Colin::Models::ContainerLocation.where(container_id: id).order(:created_at).last
  end

  acts_as_paranoid

end

