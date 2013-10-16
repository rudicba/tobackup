class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise    :ldap_authenticatable, :rememberable, :trackable
  has_many  :backups
  validates :login,     presence: true, uniqueness: true
  validates :password,  presence: true
end
