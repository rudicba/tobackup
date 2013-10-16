class Host < ActiveRecord::Base
  has_many  :backups
  validates :name, uniqueness: true, presence: true
  
  def check_status
    Timeout::timeout(5) do
      begin
        TCPSocket.new(self.ip, '22').close
        self.status = "OK"
      rescue Errno::ECONNREFUSED 
        self.status = "ECONNREFUSED"
      rescue Errno::EHOSTUNREACH
        self.status = "EHOSTUNREACH"
      end
    end
    rescue Timeout::Error
      self.status = "TIMEOUT"
  end
  
  def resolv_ip
    begin
      #self.ip = Socket::getaddrinfo(self.name,"echo",Socket::AF_INET)[0][3]
      self.ip = Resolv.getaddress(self.name)
      true
    rescue Resolv::ResolvTimeout
      self.status = "ResolvTimeout"
      false
    rescue Resolv::ResolvError
      self.status = "ResolvError"
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


