class Backup < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :host
  validates   :user_id, presence: true
  validates   :host_id, presence: true
  
end
