class FoodNutrientsController < ApplicationController
  # before_action :set_food_nutrient, only: %i[ show edit update destroy ]
  # before_action :set_food, only: %i[ show new create edit update destroy ]
  before_action :set_foods, only: %i[ nutrients_of_food new create edit update ]
  before_action :set_nutrients, only: %i[ nutrients_of_food new create edit update ]

  # # GET /food_nutrients or /food_nutrients.json
  # def index
  #   Rails.logger.debug("*** params: #{params.inspect}")
  #   @food_nutrients = FoodNutrient.all
  # end

  def nutrients_of_food
    Rails.logger.debug("*** params: #{params.inspect}")
    # set_food_nutrient_from_params('', params['food_id'])
    food_id = Integer(params[:food_id]) rescue 0
    @food = Food.find_by(id: food_id)
    if @food.blank? || @food.id.blank?
      err_msg = "cannot find food[#{params[:food_id]} - #{food_id}]"
      @food = Food.new(name: err_msg)
      @errors << err_msg
    else
      # get_nutrients_for_food
      @food_nutrients = FoodNutrient.where(food_id: @food.id)
    end
    set_flash_msg('','')
  end

  # GET /food_nutrients/1 or /food_nutrients/1.json
  def show
    set_food_nutrient_from_params(params['id'], '') # set the FoodNutrient from its id and its Food
    set_flash_msg('','')
  end

  # GET /food_nutrients/new
  def new
    set_food_nutrient_from_params('', params['food_id']) # set a new FoodNutrient for this Food
    @food_nutrient = FoodNutrient.new
    set_unused_nutrients
    set_flash_msg('','')
  end

  # GET /food_nutrients/1/edit
  def edit
    set_food_nutrient_from_params(params['id'], '') # set the FoodNutrient from its id and its Food
    set_flash_msg('','')
  end

  # POST /food_nutrients or /food_nutrients.json
  def create
    set_food_nutrient_from_params('', params['food_id']) # set a new FoodNutrient for this Food
    @food_nutrient = FoodNutrient.new(food_nutrient_params)

    respond_to do |format|
      if @food_nutrient.save
        set_flash_msg( "Food nutrient was successfully created.", '')
        format.html { redirect_to food_nutrient_url(@food_nutrient) }
        format.json { render :show, status: :created, location: @food_nutrient }
      else
        @errors + @food_nutrient.errors.full_messages
        set_flash_msg('', "ERROR: unable to create food nutrient")
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @food_nutrient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /food_nutrients/1 or /food_nutrients/1.json
  def update
    set_food_nutrient_from_params(params['id'], '') # set the FoodNutrient from its id and its Food
    @food_nutrient.assign_attributes(food_nutrient_params)
    respond_to do |format|
      if @food_nutrient.save
        set_flash_msg( "Food nutrient was successfully updated.", '')
        format.html { redirect_to food_nutrient_url(@food_nutrient), notice: "Food nutrient was successfully updated." }
        format.json { render :show, status: :ok, location: @food_nutrient }
      else
        @errors + @food_nutrient.errors.full_messages
        set_flash_msg('', "ERROR: unable to create food nutrient")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food_nutrient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /food_nutrients/1 or /food_nutrients/1.json
  def destroy
    set_food_nutrient_from_params(params['id'], '') # set the FoodNutrient from its id and its Food
    # @food_nutrient.destroy

    respond_to do |format|
      format.html { redirect_to food_nutrients_url, notice: "Food nutrient was stopped from being destroyed." }
      format.json { head :no_content }
    end
    set_flash_msg('','')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_food_nutrient
    #   @food_nutrient = FoodNutrient.find(params[:id])
    # end

    # def set_food_nutrients_from_id(food_id)
    #   @food = Food.find(@food_nutrient.food_id)
    # end

    def get_food_nutrient(id)
      food_nutrient = FoodNutrient.find_by(id: id)
      if !food_nutrient.present?
        @errors << "Missing Food Nutrient Id #{id}"
      end
      return food_nutrient
    end

    def get_food(id)
      food = Food.find_by(id: id)
      if !food.present?
        @errors << "Missing Food Id #{id}"
      end
      return food
    end

    def set_food_nutrients()
      @food_nutrients.where(food_id: food_id)
    end

    def set_foods()
      @foods = Food.all
    end

    def set_nutrients()
      @nutrients = Nutrient.all
    end

    def set_unused_nutrients()
      @unused_nutrients = Nutrient.where("NOT EXISTS (
        SELECT * FROM food_nutrients
        WHERE nutrient_id = nutrients.id AND food_id = ?)",
          @food.id
      )
    end

    def set_food_nutrient_from_params(id_param, food_id_param)
      Rails.logger.debug("$$$ set_food_nutrient_from_params - param: #{params.inspect}")
      # Rails.logger.debug("$$$ set_food_nutrient_from_params - food_nutrient_params: #{food_nutrient_params.inspect}")
      Rails.logger.debug("$$$ set_food_nutrient_from_params - id_param: #{id_param.inspect}")
      Rails.logger.debug("$$$ set_food_nutrient_from_params - food_id_param: #{food_id_param.inspect}")
      id = Integer(id_param) rescue 0
      food_id = Integer(food_id_param) rescue 0
      set_food_nutrient_from_ids(id, food_id)
    end

    def set_food_nutrient_from_ids(id, food_id)
      if id > 0
        Rails.logger.debug("$$$ get_food_nutrient(#{id})")
        @food = nil
        @food_nutrient = get_food_nutrient(id)
        if @food_nutrient.present?
          if @food_nutrient.food_id.present? && @food_nutrient.food_id > 0
            @food = get_food(@food_nutrient.food_id)
          else
            @errors << "Missing food in Food Nutrient id: #{@food_nutrient.id}"
          end
        end
      # else
      #   @errors << "Invalid Food Nutrient Id #{id}"
      end
      if @food.present? && @food.id.present?
        # food has been found from food_nutrient
      else
        Rails.logger.debug("$$$ set_food_nutrient_from_ids get_food @food: #{@food.inspect} & food_id: #{food_id}")
        @food = get_food(food_id)
      end
    end

    # Only allow a list of trusted parameters through.
    def food_nutrient_params
      params.require(:food_nutrient).permit(:id, :nutrient_id, :food_id, :study, :study_weight, :avg_rec_id, :portion, :portion_unit, :amount, :amount_unit, :desc)
    end
end
