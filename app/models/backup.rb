class Backup < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :host
  has_many    :cfiles
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

  # Sync client path to server
  def sync
    # /foo/bar/uid/bid/
    store_path = File.join(APP_CONFIG['upload_path'], self.user_id.to_s, self.id.to_s)
    # /foo/bar/uid/bid/sync
    sync_path = File.join(store_path, 'sync')
    # Get real path of client (windows to cygwin)
    client_path = self.real_path

    FileUtils.mkdir_p(sync_path) unless File.exists?(sync_path)
    
    cmd = "#{APP_CONFIG['rsync']} -ravz -e 'ssh -o StrictHostKeyChecking=no -l #{APP_CONFIG['user']}' --delete #{self.host.name}:#{client_path} #{sync_path}" 
    
    puts(cmd) 
    begin
      PTY.spawn(cmd) do |r, w|
        w.sync = true
        puts("login...")
        r.expect(/assword:/) { w.puts("#{APP_CONFIG['pass']}\n") }
        puts("waiting finish.")
        r.expect(/rsync error|done/,10) do |line|
          if line.to_s.include?("rsync error") then
            puts("Rsync error")
            self.status = "rsync error"
          else
            puts("Rsync OK")
            self.status = "ok"
          end
        end
      end
    rescue PTY::ChildExited => e
      puts PTY::ChildExited[" + e.status + "]
    rescue => e
      puts e.class.to_s + "[" + e.message + "]"
    end

    self.last = Time.now

    self.zip 

    self.save
  end
   
  # EN DESUSO, SOLO FINES INFORMATIVOS	 
  def create_backup

    # /foo/bar/uid/bid/
    store_path = File.join(APP_CONFIG['upload_path'], self.user_id.to_s, self.id.to_s)

    # /foo/bar/uid/bid/last
    last_path = File.join(store_path, 'last')
    
    # Create /foo/bar/uid/bid/last
    FileUtils.mkdir_p(last_path) unless File.exists?(last_path)
    
    # Get real path of client (windows to cygwin)
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

    # Create zip from last store_path
    self.zip 
    
    self.save
  end
  
  def zip
    # Convert again to time => (t = time.at(i))
    current_time = Time.now

    # /foo/bar/uid/bid/
    store_path = File.join(APP_CONFIG['upload_path'], self.user_id.to_s, self.id.to_s)

    # /foo/bar/uid/bid/last
    sync_path = File.join(store_path, 'sync')

    # self.path = /client/foo/bar/backupme
    # file      = backupme   
    filename = File.basename(self.path)
   
    # /foo/bar/uid/bid/000000000.tgz
    zipfile_name = File.join(store_path, "#{current_time.to_i}.tgz")
    
    system("tar -czf #{zipfile_name} -C #{sync_path} #{filename}")
    
    self.cfiles.build(path: zipfile_name, date: current_time)
  end
end
