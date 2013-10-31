class Cfile < ActiveRecord::Base
  belongs_to :backup
  before_destroy :remove_cfile
  before_save :update_filesize
  
  private
  
  # Remove file from HardDisk
  def remove_cfile
    begin
      FileUtils.rm self.path.to_s
    rescue
      p self.path.to_s + 'can not be deleted'
    end
  end
  
  # Sotre FileSize on Database
  def update_filesize
    self.size = File.size? self.path.to_s
  end
  
end
