class Backup < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :host
  has_many    :backup_files
  validates   :user_id, presence: true
  validates   :host_id, presence: true
  validates   :path, presence: true
  
  # Convert windows path to cygwin path
  # c:/Mis documentos -> /cygdrive/c/Mis documentos
  def real_path
  	if self.host.cygwin
  		"/cygdrive/#{self.path[0]}#{self.path[2..-1]}"
  	else
  		self.path
  	end
  end
    
  def create_backup

    # Where to store backup
    # /upload/path/uid/bid/last
    store_path = File.join(APP_CONFIG['upload_path'], self.user_id.to_s, self.id.to_s)
    last_path = File.join(store_path, 'last')
    
    # Create /upload/path/uid/bid
    FileUtils.mkdir_p(last_path) unless File.exists?(last_path)
    
    # Get real path of client
    client_path = self.real_path
	
    begin Timeout::timeout(5) do
      begin
        Net::SCP.download!( self.host.name,                               # Host to backup
                            APP_CONFIG['user'],                           # User to connect
                            client_path,                                  # Remote path
                            last_path,                                    # Last path
                            :recursive => true,                           # Recursive
                            :ssh => { :password => APP_CONFIG['pass'] } ) # Pass
        self.status = "ok"
        self.last = Time.now
      rescue Exception => msg
        self.status = msg.to_s
      end
    end
    rescue Exception => msg
      self.status = msg.to_s
    end
    
    # New Backupfile
    #@backupfile = self.backup_files.build()
    
    # Create zip from last store_path
    self.zip 
    
    self.save
  end
  
  def zip
    current_time = Time.now
    date = current_time.strftime("%d-%m-%Y")
    time = current_time.strftime("%I:%M%p")
    
    store_path = File.join(APP_CONFIG['upload_path'], self.user_id.to_s, self.id.to_s)
    last_path = File.join(store_path, 'last')
    file = File.basename(self.path)
   
    zipfile_name = File.join(store_path, "#{date}-#{time}.tgz")
    
    
    system("tar -czf #{zipfile_name} -C #{last_path} #{file}")
    
    self.backup_files.build(path: zipfile_name)
   
    # Store in DB where is zip
    #self.path = zipfile_name
  end
  
  def generate_tgz
    tmpname = rand(36**8).to_s(8)
    local_path = File.join(APP_CONFIG['upload_path'], self.user_id.to_s, self.id.to_s)
    file = File.basename(self.path)
    
    if system("tar -czf #{Rails.root}/tmp/#{tmpname}.tgz -C #{local_path} #{file}")
      content = File.read("#{Rails.root}/tmp/#{tmpname}.tgz")
    end
  end
end
