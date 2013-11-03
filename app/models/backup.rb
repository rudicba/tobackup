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
    
    cmd = "#{APP_CONFIG['rsync_path']} -r -a -v -e \"ssh -o StrictHostKeyChecking=no -l #{APP_CONFIG['rsync_user']}\" --delete #{self.host.name}:#{client_path} #{sync_path}" 
    
    puts(cmd) 
    begin
      PTY.spawn(cmd) do |r, w|
        w.sync = true
        puts("login...")
        r.expect(/assword:/) { w.puts("#{APP_CONFIG['rsync_pass']}\n") }
        puts("waiting finish.")
        r.expect(/total size/) do |l|
          puts(l.to_s)
          puts("done.\n")
        end
      end
    rescue PTY::ChildExited => e
      puts("rsync process finished.\n")
    end

    self.last = Time.now
    self.status = "ok"

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
