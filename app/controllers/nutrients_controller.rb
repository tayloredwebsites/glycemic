class NutrientsController < ApplicationController
  before_action :set_nutrient, only: %i[ show edit update destroy ]

  # GET /nutrients or /nutrients.json
  def index
    @nutrients = Nutrient.all
  end

  # GET /nutrients/1 or /nutrients/1.json
  def show
  end

  # GET /nutrients/new
  def new
    @nutrient = Nutrient.new
  end

  # GET /nutrients/1/edit
  def edit
  end

  # POST /nutrients or /nutrients.json
  def create
    @nutrient = Nutrient.new(nutrient_params)

    respond_to do |format|
      if @nutrient.save
        format.html { redirect_to nutrient_url(@nutrient), notice: "Nutrient was successfully created." }
        format.json { render :show, status: :created, location: @nutrient }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @nutrient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nutrients/1 or /nutrients/1.json
  def update
    respond_to do |format|
      if @nutrient.update(nutrient_params)
        format.html { redirect_to nutrient_url(@nutrient), notice: "Nutrient was successfully updated." }
        format.json { render :show, status: :ok, location: @nutrient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @nutrient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nutrients/1 or /nutrients/1.json
  def destroy
    @nutrient.destroy

    respond_to do |format|
      format.html { redirect_to nutrients_url, notice: "Nutrient was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nutrient
      @nutrient = Nutrient.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def nutrient_params
      params.require(:nutrient).permit(:id, :name, :usda_ndb_num, :desc)
    end
end
