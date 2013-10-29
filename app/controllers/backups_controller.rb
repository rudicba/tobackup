class BackupsController < ApplicationController
  before_action :set_backup, only: [:show, :edit, :update, :destroy, :now, :download]
  before_filter :authenticate_user!

  # GET /backups
  # GET /backups.json
  def index
    #@backups = Backup.all
    @backups = current_user.backups
  end

  # GET /backups/1
  # GET /backups/1.json
  def show
  end
  
  # PATCH /backup/1/now
  def now
    @backup.create_backup
    if @backup.status == "ok"
      redirect_to backups_path, notice: 'Backup was successfully upload.'
    else
      redirect_to backups_path, notice: "Backup problem: #{@backup.status}"
    end
  end
  
  # PATCH /backup/1/download
  def download
    send_data @backup.generate_tgz, :filename => 'backup.tgz'   
  end

  # GET /backups/new
  def new
    @backup = Backup.new
    begin 
      hostname = Resolv.getname(request.remote_ip)
    rescue
      hostname = ""
    end
      
    @backup.host = Host.find_by_name(hostname)
  end

  # GET /backups/1/edit
  def edit
  end

  # POST /backups
  # POST /backups.json
  def create
    @backup = current_user.backups.build(backup_params)
    @backup.user = current_user

    respond_to do |format|
      if @backup.save
        format.html { redirect_to backups_path, notice: 'Backup was successfully created.' }
        format.json { render action: 'show', status: :created, location: @backup }
      else
        format.html { render action: 'new' }
        format.json { render json: @backup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /backups/1
  # PATCH/PUT /backups/1.json
  def update
    respond_to do |format|
      if @backup.update(backup_params)
        format.html { redirect_to backups_path, notice: 'Backup was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @backup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /backups/1
  # DELETE /backups/1.json
  def destroy
    @backup.destroy
    respond_to do |format|
      format.html { redirect_to backups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_backup
      @backup = Backup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def backup_params
      params.require(:backup).permit(:path, :user_id, :host_id)
    end
end
