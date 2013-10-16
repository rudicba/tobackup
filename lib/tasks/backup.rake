def scpdownload (backup)
  username    = APP_CONFIG['user']
  password    = APP_CONFIG['pass']
  base        = APP_CONFIG['upload_path']
  hostname    = backup.host.name
  path        = backup.path
  
  download_to = File.join(base, backup.user_id.to_s, backup.id.to_s)
  
  FileUtils.mkdir_p(download_to.to_s) unless File.exists?(download_to.to_s)
 
  Net::SSH.start( hostname, username, :password => password ) do |ssh|
    ssh.scp.download!( path, download_to, :recursive => true )
  end 
end

task :cron_scp => :environment do
  Host.all.each do |host|
    host.backups.all.each do |backup|
      scpdownload backup
    end
  end  
end





def sftpdownload (uid, bid, host, path)
  user        = APP_CONFIG['user']
  pass        = APP_CONFIG['pass']

  Net::SFTP.start(host, user, :password => pass) do |sftp|
    download_path uid, bid, sftp, path
  end
end

def download_path (uid, bid, sftp, remote_path)
  sftp.dir.foreach(remote_path) do |file|
    next if file.name == "." || file.name == ".."
    if file.attributes.file?
      download_file uid, bid, sftp, remote_path, file 
    else
      new_path = File.join(remote_path, file.name) 
      download_path uid, bid, sftp, new_path
    end
  end
end

def download_file (uid, bid, sftp, remote_path, file)
  base = APP_CONFIG['file_upload']
  local_file = File.join(base, uid, bid, remote_path, file.name)
  
  begin
    remote_file_changed =  Time.at(file.attributes.mtime) > File.stat(local_file).mtime
  rescue Errno::ENOENT 
    not_downloaded = true 
  end
  
  if not_downloaded or remote_file_changed
    puts "#{file.name} has changed and will be uploaded"
     
    #sftp.download!(remote_path + file.name, file_tmp)
  end 
      
end



task :cron_sftp => :environment do
  Host.all.each do |host|
    host.backups.all.each do |backup|
      sftpdownload backup.user_id.to_s, backup.host_id.to_s, backup.host.name, backup.path
    end
  end  
end

