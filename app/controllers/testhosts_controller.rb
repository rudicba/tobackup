class TesthostsController < ApplicationController
  before_action :set_testhost, only: [:show, :edit, :update, :destroy]

  # GET /testhosts
  # GET /testhosts.json
  def index
    @testhosts = Testhost.all
  end

  # GET /testhosts/1
  # GET /testhosts/1.json
  def show
  end

  # GET /testhosts/new
  def new
    @testhost = Testhost.new
  end

  # GET /testhosts/1/edit
  def edit
  end

  # POST /testhosts
  # POST /testhosts.json
  def create
    @testhost = Testhost.new(testhost_params)

    respond_to do |format|
      if @testhost.save
        format.html { redirect_to @testhost, notice: 'Testhost was successfully created.' }
        format.json { render action: 'show', status: :created, location: @testhost }
      else
        format.html { render action: 'new' }
        format.json { render json: @testhost.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /testhosts/1
  # PATCH/PUT /testhosts/1.json
  def update
    respond_to do |format|
      if @testhost.update(testhost_params)
        format.html { redirect_to @testhost, notice: 'Testhost was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @testhost.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /testhosts/1
  # DELETE /testhosts/1.json
  def destroy
    @testhost.destroy
    respond_to do |format|
      format.html { redirect_to testhosts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_testhost
      @testhost = Testhost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def testhost_params
      params.require(:testhost).permit(:name, :ip, :status)
    end
end
