class Colin::Models::User < ActiveRecord::Base

  validates :username, presence: true, uniqueness: true
  validates_presence_of :name
  validates_presence_of :email

  has_secure_password

  def slug
    self.username
  end

  def self.find_by_slug(slug) 
    User.all.find{|user| user.slug == slug}
  end
end
