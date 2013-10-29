require 'resolv'

class Host < ActiveRecord::Base
  has_many  :backups
  validates :name, uniqueness: true, presence: true
  
  def check_status
    begin 
      Timeout::timeout(5) do
        begin 
          TCPSocket.new(self.ip, '22').close
          self.status = "OK"
        rescue Exception => msg 
          self.status = msg.to_s 
        end
      end # Timeout block
    rescue Exception => msg 
      self.status = msg.to_s 
    end
  end
  
  def resolv_ip
    begin
      self.ip = Resolv.getaddress(self.name)
      true
    rescue Exception => msg
      self.status = msg.to_s 
      false
    end
  end

  def update_status
    if self.resolv_ip
      self.check_status
    end
    self.save
  end
end


