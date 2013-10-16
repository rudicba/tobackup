class Backup < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :host
  validates   :user_id, presence: true
  validates   :host_id, presence: true
  
  def create_backup
    # Where to store backup
    # /upload/path/uid/bid
    local_path = File.join(APP_CONFIG['upload_path'], self.user_id.to_s, self.id.to_s)
    
    # Create /upload/path/uid/bid
    FileUtils.mkdir_p(local_path) unless File.exists?(local_path)
    begin
      Net::SCP.download!( self.host.name,                               # Host to backup
                          APP_CONFIG['user'],                           # User to connect
                          self.path,                                    # Remote path
                          local_path,                                   # Local path
                          :recursive => true,                           # Recursive
                          :ssh => { :password => APP_CONFIG['pass'] })  # Pass
      self.status = "ok"
      self.lase = Time.now
    rescue Exception => msg
      self.status = msg.to_s
    end
       
    self.save
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
