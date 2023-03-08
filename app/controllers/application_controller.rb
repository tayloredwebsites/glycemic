# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :init_errors

  def init_errors()
    @errors = []
  end

  def set_flash_msg(success_msg, err_msg)
    Rails.logger.debug("$$$ set_flash_msg success_msg: #{success_msg}, err_msg: #{err_msg} )")
    Rails.logger.debug("$$$ debugging @errors.count: #{@errors.count} )")
    Rails.logger.debug("$$$ debugging @food_nutrient: #{@food_nutrient.id} )") if @food_nutrient.present?
    Rails.logger.debug("$$$ debugging @food_nutrients.count: #{@food_nutrients.count} )") if @food_nutrients.present?
    Rails.logger.debug("$$$ debugging @food: #{@food.id} - #{@food.name} )") if @food.present?
    Rails.logger.debug("$$$ debugging @foods.count: #{@foods.count}: ") if @foods.present?
    Rails.logger.debug("$$$ debugging @nutrient: #{@nutrient.id} )") if @nutrient.present?
    Rails.logger.debug("$$$ debugging @nutrients.count: #{@nutrients.count} )") if @nutrients.present?
    Rails.logger.debug("$$$ debugging @unused_nutrients.count: #{@unused_nutrients.count} )") if @unused_nutrients.present?
    if @errors.count > 0 || err_msg.present?
      Rails.logger.error("ERROR: #{err_msg}")
      @errors.each do |err|
        Rails.logger.error("ERROR: #{err}")
      end
      flash[:alert] = "ERROR: #{err_msg}: #{@errors.join("; ")}"
      # print success message if it was passed to us regardless
      flash[:notice] = success_msg if success_msg.present?
    else
      flash[:notice] = success_msg
    end
  end

end
