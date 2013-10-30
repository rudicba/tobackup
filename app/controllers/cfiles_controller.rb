class CfilesController < ApplicationController
  before_action :set_cfile, only: [:show, :edit, :update, :destroy, :now, :download]
  before_filter :authenticate_user!

  def index
    # Get Backup
    @backups = Backup.find(params[:backup_id])
    @cfiles = @backups.cfiles
  end

  def download
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
