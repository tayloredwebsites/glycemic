# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require "application_system_test_case"

class FoodsTest < ApplicationSystemTestCase
  setup do
    @food = foods(:one)
  end

  test "visiting the index" do
    visit foods_path
    assert_selector "h1", text: "Foods"
  end

  test "should create food" do
    visit foods_path
    click_on "New food"

    fill_in "Desc", with: @food.desc
    fill_in "Id", with: @food.id
    fill_in "Name", with: @food.name
    fill_in "Usda fdc", with: @food.usda_fdc_id
    click_on "Create Food"

    assert_text "Food was successfully created"
    click_on "Back"
  end

  test "should update Food" do
    visit food_path(@food)
    click_on "Edit this food", match: :first

    fill_in "Desc", with: @food.desc
    fill_in "Id", with: @food.id
    fill_in "Name", with: @food.name
    fill_in "Usda fdc", with: @food.usda_fdc_id
    click_on "Update Food"

    assert_text "Food was successfully updated"
    click_on "Back"
  end

  test "should destroy Food" do
    visit food_path(@food)
    click_on "Destroy this food", match: :first

    assert_text "Food was successfully destroyed"
  end
end
