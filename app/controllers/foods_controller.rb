class FoodsController < ApplicationController
  before_action :set_food, only: %i[ show edit update destroy ]

  # GET /foods or /foods.json
  def index
    Rails.logger.debug("*** params: #{params.inspect}")
    @showing_active = params[:showing_active]
    @foods = Food
    if @showing_active == 'all'
      Rails.logger.debug("$$$ Show all Food records")
      @foods = @foods.all
    elsif @showing_active == 'deact'
      Rails.logger.debug("$$$ Show deactivated Food records")
      @foods = @foods.deact_foods
    else
      # default - show active food nutrients
      Rails.logger.debug("$$$ Show active Food records")
      @foods = @foods.active_foods
    end
  end

  # GET /foods/1 or /foods/1.json
  def show
  end

  # GET /foods/new
  def new
    @food = Food.new
  end

  # GET /foods/1/edit
  def edit
  end

  # POST /foods or /foods.json
  def create
    @food = Food.new(food_params)

    respond_to do |format|
      if @food.save
        format.html { redirect_to food_url(@food), notice: "Food was successfully created." }
        format.json { render :show, status: :created, location: @food }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @food.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /foods/1 or /foods/1.json
  def update
    respond_to do |format|
      if @food.update(food_params)
        format.html { redirect_to food_url(@food), notice: "Food was successfully updated." }
        format.json { render :show, status: :ok, location: @food }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /foods/1 or /foods/1.json
  def destroy
    save_name = @food.name
    @food.active = false
    if @food.save
      Rails.logger.debug("$$$ deactivated food: #{@food.inspect}")
      Rails.logger.debug("$$$ deactivated food: #{save_name}")
      set_flash_msg("Successfully deactivated #{save_name}", "")

    else
      set_flash_msg('', "Error deactivated food: #{@food.name}")
      @errors + @food.errors.full_messages
    end
    respond_to do |format|
      format.html { redirect_to foods_url, notice: "Food was successfully deactivated." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_food
      @food = Food.active_foods.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def food_params
      params.require(:food).permit(:id, :name, :desc, :usda_fdc_id)
    end
end
