class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :init_errors

  def init_errors()
    @errors = []
  end

  def set_flash_msg(success_msg, err_msg)
    Rails.logger.debug("$$$ set_flash_msg debugging @errors.count: #{@errors.count} )")
    Rails.logger.debug("$$$ set_flash_msg debugging @food_nutrient: #{@food_nutrient.id} )") if @food_nutrient.present?
    Rails.logger.debug("$$$ set_flash_msg debugging @food_nutrients.count: #{@food_nutrients.count} )") if @food_nutrients.present?
    Rails.logger.debug("$$$ set_flash_msg debugging @food: #{@food.id} - #{@food.name} )") if @food.present?
    Rails.logger.debug("$$$ set_flash_msg debugging @foods.count: #{@foods.count}: ") if @foods.present?
    Rails.logger.debug("$$$ set_flash_msg debugging @nutrient: #{@nutrient.id} )") if @nutrient.present?
    Rails.logger.debug("$$$ set_flash_msg debugging @nutrients.count: #{@nutrients.count} )") if @nutrients.present?
    Rails.logger.debug("$$$ set_flash_msg debugging @unused_nutrients.count: #{@unused_nutrients.count} )") if @unused_nutrients.present?
    if @errors.count > 0
      Rails.logger.error("ERROR: #{err_msg}")
      @errors.each do |err|
        Rails.logger.error("ERROR: #{err}")
      end
      flash[:alert] = "ERROR: #{err_msg}: #{@errors.join("; ")}"
    else
      flash[:notice] = success_msg
    end
  end

end
