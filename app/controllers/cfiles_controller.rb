class CfilesController < ApplicationController
  before_action :set_cfile, only: [:destroy, :download]
  before_filter :authenticate_user!

  # GET /backups/:backup_id/cfiles
  # GET /backups/:backup_id/cfiles  .xml
  def index
    # Get Backup
    @backup = Backup.find(params[:backup_id])
    @cfiles = @backup.cfiles
  end

  # GET /backups/:backup_id/cfile/:id
  # GET /cfile/:id.xml
  def download
    send_file @cfile.path.to_s
  end
  
  # DELETE /backups/1
  # DELETE /backups/1.json
  def destroy
    @cfile.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cfile
      @cfile =Cfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cfile_params
      params.require(:cfile).permit()
    end
end
