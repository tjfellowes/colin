class Colin::Models::User < ActiveRecord::Base
  default_scope {where(active: TRUE)}

  validates :username, presence: true, uniqueness: true
  validates_presence_of :name
  validates_presence_of :email

  has_many :underlings, class_name: "User", foreign_key: "supervisor_id"
  belongs_to :supervisor, class_name: "User"

  has_secure_password

  def slug
    self.username
  end

  def self.find_by_slug(slug) 
    User.all.find{|user| user.slug == slug}
  end
end
