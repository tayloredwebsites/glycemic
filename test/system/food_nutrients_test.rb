# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require "application_system_test_case"

class FoodNutrientsTest < ApplicationSystemTestCase
  setup do
    @food_nutrient = food_nutrients(:one)
  end

  test "visiting the index" do
    visit food_nutrients_path
    assert_selector "h1", text: "Food nutrients"
  end

  test "should create food nutrient" do
    visit food_nutrients_path
    click_on "New food nutrient"

    fill_in "Amount", with: @food_nutrient.amount
    fill_in "Amount unit", with: @food_nutrient.amount_unit
    fill_in "Avg rec", with: @food_nutrient.avg_rec_id
    fill_in "Desc", with: @food_nutrient.desc
    fill_in "Food", with: @food_nutrient.food_id
    fill_in "Id", with: @food_nutrient.id
    fill_in "Nutrient", with: @food_nutrient.nutrient_id
    fill_in "Portion", with: @food_nutrient.portion
    fill_in "Portion unit", with: @food_nutrient.portion_unit
    check "Study" if @food_nutrient.study
    fill_in "Study weight", with: @food_nutrient.study_weight
    click_on "Create Food nutrient"

    assert_text "Food nutrient was successfully created"
    click_on "Back"
  end

  test "should update Food nutrient" do
    visit food_nutrient_path(@food_nutrient)
    click_on "Edit this food nutrient", match: :first

    fill_in "Amount", with: @food_nutrient.amount
    fill_in "Amount unit", with: @food_nutrient.amount_unit
    fill_in "Avg rec", with: @food_nutrient.avg_rec_id
    fill_in "Desc", with: @food_nutrient.desc
    fill_in "Food", with: @food_nutrient.food_id
    fill_in "Id", with: @food_nutrient.id
    fill_in "Nutrient", with: @food_nutrient.nutrient_id
    fill_in "Portion", with: @food_nutrient.portion
    fill_in "Portion unit", with: @food_nutrient.portion_unit
    check "Study" if @food_nutrient.study
    fill_in "Study weight", with: @food_nutrient.study_weight
    click_on "Update Food nutrient"

    assert_text "Food nutrient was successfully updated"
    click_on "Back"
  end

  test "should destroy Food nutrient" do
    visit food_nutrient_path(@food_nutrient)
    click_on "Destroy this food nutrient", match: :first

    assert_text "Food nutrient was successfully destroyed"
  end
end
