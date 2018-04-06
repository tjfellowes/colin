#
# Storage Class model class.
#
class Colin::Models::StorageClass < ActiveRecord::Base
  validates_presence_of :name
end
