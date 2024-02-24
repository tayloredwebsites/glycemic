# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class FoodNutrientsController < ApplicationController
  before_action :set_food_nutrient_from_params, except: %i[]
  before_action :set_food_from_params, except: %i[]
  # before_action :set_food_nutrient, only: %i[ show edit update destroy ]
  # before_action :set_food, only: %i[ show new create edit update destroy ]
  before_action :set_foods, only: %i[nutrients_of_food new create edit update]
  before_action :set_nutrients, only: %i[nutrients_of_food new create edit update]

  # # GET /food_nutrients or /food_nutrients.json
  # def index
  #   Rails.logger.debug("*** params: #{params.inspect}")
  #   @food_nutrients = FoodNutrient.all
  # end

  def nutrients_of_food
    Rails.logger.debug("*** params: #{params.inspect}")
    @showing_active = params[:showing_active]
    food_id = params[:food_id].to_i()
    # find food, regardless if it is active or not
    @food = Food.find_by(id: food_id)
    if @food.blank? || @food.id.blank?
      err_msg = "cannot find food[#{params[:food_id]} - #{food_id}]"
      @food = Food.new(name: err_msg)
      @errors << err_msg
    else
      # get_nutrients_for_food
      @food_nutrients = FoodNutrient
      if @showing_active == 'all'
        Rails.logger.debug("$$$ Show all FoodNutrient records")
        @food_nutrients = @food_nutrients.where(food_id: @food.id)
      elsif @showing_active == 'deact'
        Rails.logger.debug("$$$ Show deactivated FoodNutrient records")
        @food_nutrients = @food_nutrients.deact_food_nutrients.where(food_id: @food.id)
      else
        # default - show_nutrient active food nutrients
        Rails.logger.debug("$$$ Show active FoodNutrient records")
        @food_nutrients = @food_nutrients.active_food_nutrients.where(food_id: @food.id)
      end
    end
    set_flash_msg('', '')
  end

  # GET /food_nutrients/1 or /food_nutrients/1.json
  def show
    set_flash_msg('', '')
  end

  # GET /food_nutrients/new
  def new
    Rails.logger.debug("*** params: #{params.inspect}")
    @food = Food.find(params[:food_id])
    Rails.logger.debug("*** @food: #{@food.inspect}")
    @food_nutrient = FoodNutrient.new(food_id: @food.id)
    set_unused_nutrients
    set_flash_msg('', '')
  end

  # GET /food_nutrients/1/edit
  def edit
    set_unused_nutrients
    set_flash_msg('', '')
  end

  # POST /food_nutrients or /food_nutrients.json
  def create
    @food_nutrient = FoodNutrient.new(food_nutrient_params)
    @food_nutrient.samples_json = "" if  @food_nutrient.samples_json.nil?

    respond_to do |format|
      if @food_nutrient.save
        msg = "Food nutrient was successfully created, redirect_to '/nutrients_of_food/#{@food_nutrient.food_id}'"
        Rails.logger.debug(msg)
        set_flash_msg(msg, '')
        format.html { redirect_to "/nutrients_of_food/#{@food_nutrient.food_id}", notice: "Food nutrient was successfully created." }
        format.json { render :show, status: :created, location: @food_nutrient }
      else
        msg = @errors + @food_nutrient.errors.full_messages
        errMsg = "ERROR: unable to create food nutrient: #{msg.join('; ')}"
        Rails.logger.error(errMsg)
        set_flash_msg(errMsg)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @food_nutrient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /food_nutrients/1 or /food_nutrients/1.json
  def update
    cleaned_food_nutrient_params = food_nutrient_params.except(
      :nutrient_id,  # do not let foreign key be changed
      :food_id,  # do not let foreign key be changed
    )
    @food_nutrient.assign_attributes(cleaned_food_nutrient_params)
    respond_to do |format|
      if @food_nutrient.save
        msg = "Food nutrient was successfully updated, redirect_to '/nutrients_of_food/#{@food_nutrient.food_id}'"
        Rails.logger.debug(msg)
        set_flash_msg(msg, '')
        format.html { redirect_to "/nutrients_of_food/#{@food_nutrient.food_id}", notice: "Food nutrient was successfully created." }
        format.json { render :show, status: :ok, location: @food_nutrient }
      else
        # @errors + @food_nutrient.errors.full_messages
        set_flash_msg('', "ERROR: unable to create food nutrient")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food_nutrient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /food_nutrients/1 or /food_nutrients/1.json
  def destroy
    @food_nutrient.active = false
    save_id = @food_nutrient.id
    save_food_id = @food_nutrient.food_id
    if @food_nutrient.save
      Rails.logger.debug("$$$ deactivated food: #{@food_nutrient.inspect}")
      Rails.logger.debug("$$$ deactivated food: #{save_id}")
      set_flash_msg("Successfully deactated #{save_id}", "")
    else
      set_flash_msg('', "Error deactivating food: #{@food_nutrient.id}")
      @errors + @food_nutrient.errors.full_messages.join(', ')
    end

    respond_to do |format|
      format.html do
        if @errors.count > 0
          redirect_to food_nutrients_url, notice: "Food nutrient was stopped from being destroyed."
        else
          redirect_to "/nutrients_of_food/#{save_food_id}"
        end
      end
      format.json { head :no_content }
    end
    set_flash_msg('', '')
  end

  def reactivate
    Rails.logger.debug("$$$ Reactivate - params: #{params.inspect}")
    respond_to do |format|
      if @food_nutrient.update(active: true)
        format.html { redirect_to nutrients_of_food_url(@food_nutrient.food_id), notice: "Food nutrient was successfully reactivated." }
        format.json { render :show, status: :ok, location: @food_nutrient }
      else
        set_flash_msg('', "ERROR: unable to deactivate food nutrient")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food_nutrient.errors, status: :unprocessable_entity }
      end
    end
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
    if food_nutrient.blank?
      @errors << "Missing Food Nutrient Id #{id}"
    end
    return food_nutrient
  end

  def get_food(id)
    food = Food.active_foods.find_by(id: id)
    if food.blank?
      @errors << "Missing Food Id #{id}"
    end
    return food
  end

  def set_foods()
    @foods = Food.active_foods
  end

  def set_nutrients()
    @nutrients = Nutrient
  end

  # TODO: review this
  def set_unused_nutrients()
    @unused_nutrients = Nutrient.active_nutrients.where("NOT EXISTS (
        SELECT * FROM food_nutrients
        WHERE nutrient_id = nutrients.id AND food_id = ? AND food_nutrients.active = true)",
      @food.id)
  end

  # get food_nutrient from either the food_nutrient id or food id params
  def set_food_nutrient_from_params()
    Rails.logger.debug("$$$ set_food_nutrient_from_params - param: #{params.inspect}")
    if params[:id]
      @food_nutrient = FoodNutrient.find_by(id: params[:id])
    else
      @food_nutrient = FoodNutrient.new()
    end
    Rails.logger.debug("*** set_food_nutrient_from_params - @food_nutrient.id: #{@food_nutrient.id}")
  end

  # get food from either the food_nutrient id or food id params
  # run set_food_nutrient_from_params before this
  def set_food_from_params()
    # Rails.logger.debug("$$$ set_food_from_params - param: #{params.inspect}")
    # Rails.logger.debug("*** set_food_from_params - @food_nutrient: #{@food_nutrient.inspect}")
    # Rails.logger.debug("*** set_food_from_params - defined?(@food_nutrient).present?: #{defined?(@food_nutrient).present?}")
    if defined?(@food_nutrient).present?
      @food = Food.find_by(id: @food_nutrient.food_id)
      # Rails.logger.debug("*** set_food_from_params - @food_nutrient - @food.id: #{@food.id}")
    elsif params[:food_id].present?
      @food = Food.find_by(id: params[:food_id])
      # Rails.logger.debug("*** set_food_from_params - @food.id: #{@food.id}")
    else 
      @food_nutrient.errors.add(:food_id, "Missing food_id for food nutrient")
      @food = Food.new
    end
    # Rails.logger.debug("*** set_food_from_params done - @food.id: #{@food.id}")
    # Rails.logger.debug("*** set_food_from_params done - @food_nutrient.id: #{@food_nutrient.id}")
  end

  # Only allow a list of trusted parameters through.
  def food_nutrient_params
    params.require(:food_nutrient).permit(
      :id,
      :nutrient_id,
      :food_id,
      # :study,
      # :study_weight,
      # :avg_rec_id,
      :portion,
      :portion_unit,
      :amount,
      :amount_unit,
      :desc,
      :showing_active,
    )
  end
end
